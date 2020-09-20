//
//  AudioManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import AVFoundation
import SummerSlider
import DataCompression

class AudioManager:NSObject, AVAudioPlayerDelegate , AVAudioRecorderDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var audioData = Data()

    
    func startRecord(){
        checkRecordPermission()
        setUpRecord()
    }
    
    func beginRecording(){
        if audioRecorder?.isRecording == false {
            if audioRecorder != nil{
                audioRecorder?.record()
            }
        }
    }
    
    func playPauseRecord() {
        if audioPlayer != nil{
            if (audioPlayer!.isPlaying == true) {
                audioPlayer!.stop()
            }else{
                audioPlayer!.play()
            }
        }
    }
    
    func playRecord(){
        print("playRecord")
        if audioRecorder?.isRecording == false {
            do {
                if audioPlayer == nil{
                    try audioPlayer = AVAudioPlayer(contentsOf:
                        (audioRecorder?.url)!)
                    //                let audioData =  try Data(contentsOf: (audioRecorder?.url)!)
                    //                let encodedString = audioData.base64EncodedString()
                    //                print("encodedString: \(encodedString)")
                    audioPlayer!.delegate = self
                    audioPlayer!.prepareToPlay()
                    audioPlayer!.play()
                    
                }else{
                    //                    audioPlayer!.prepareToPlay()
                    audioPlayer!.play()
                }
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func pauseRecord() {
        if audioPlayer != nil{
            if (audioPlayer!.isPlaying == true) {
                audioPlayer!.stop()
            }
        }
    }
    
    @objc func saveRecord(){
        print("saveRecord")
        // stop recording
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        }else{
            audioPlayer?.stop()
        }
        
        do {
            
            audioData =  try Data(contentsOf: (audioRecorder?.url)!)
            
            let size = Double(audioData.count) / ( 1024.0 * 1024.0)
            print("File size in MB: ", size)
//                        let compressedData = audioData.compress(withAlgorithm: .lzma)
//                        let sizeafter = Double(compressedData!.count) / ( 1024.0 * 1024.0)
//                        print("File after compress size in MB: ", sizeafter)
            
            if let navView = self.topMostController() as?  UINavigationController {
                if let view = navView.topViewController as? RequestFromStoreVC{
                    print("It's an AnyObject: RequestFromStoreVC")
                    view.saveRecordData(recordData: audioData)
                }else{
                    print("It's not an edit AnyObject.")
                    
                }
                
            }else {
                print("It's not an nav AnyObject.")
            }
            
            //                let encodedString = audioData.base64EncodedString()
            //                print("encodedString: \(encodedString)")
            
        } catch let error as NSError {
            print("audioPlayer error: \(error.localizedDescription)")
        }
        
    }
    
    func stopRecorderAndPlayer(){
        if audioRecorder != nil{
            audioRecorder?.stop()
            audioRecorder = nil
        }
        
        if audioPlayer != nil{
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }
    
    func stopRecorder(){
        if audioRecorder != nil{
            audioRecorder?.stop()
        }
    }

    func setUpRecord(){
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.wav")
        
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
             //             AVFormatIDKey:Int(kAudioFormatAMR),
                AVEncoderBitRateKey: 16,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0] as [String : Any]
        
        //        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func checkRecordPermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            print("RecordPermission.granted")
            break
        case AVAudioSession.RecordPermission.denied:
            print("RecordPermission.denied")
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    print("allowed")
                } else {
                    print("not allowed")
                }
            })
            break
        default:
            break
        }
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
}
