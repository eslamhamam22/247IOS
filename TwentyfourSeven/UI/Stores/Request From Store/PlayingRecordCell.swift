//
//  PlayingRecordCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import SummerSlider
import NVActivityIndicatorView

class PlayingRecordCell: UITableViewCell {

    @IBOutlet weak var playRecordIcon : UIImageView!
    @IBOutlet weak var recordSlider:SummerSlider!
    @IBOutlet weak var playRecordBgView : UIView!
    @IBOutlet weak var playingTimerLbl : UILabel!
    @IBOutlet weak var recordTimeLbl : UILabel!
    @IBOutlet weak var deleteRecordIcon : UIImageView!
    @IBOutlet weak var uploadingProgressView: NVActivityIndicatorView!
    
    var timer = Timer()
    var totalTimeCount = 0.0
    var recordValue = 0.0
    var viewedTimeCount = 0.0
    var delegate: RequestFromStoreDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCell(totalTimeCount: Double,recordTime: String, delegate: RequestFromStoreDelegate){
        
        self.totalTimeCount = totalTimeCount
        self.viewedTimeCount = totalTimeCount
        self.delegate = delegate
        uploadingProgressView.type = .ballRotateChase
        uploadingProgressView.color = UIColor.red
        uploadingProgressView.tintColor = UIColor.red
        deleteRecordIcon.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishPlaying), name: NSNotification.Name(rawValue: "finishPlaying"), object: nil)

        recordTimeLbl.text = recordTime
        recordTimeLbl.font = Utils.customDefaultFont(recordTimeLbl.font.pointSize)
        playingTimerLbl.font = Utils.customDefaultFont(playingTimerLbl.font.pointSize)
        playingTimerLbl.isHidden = true
        
        setGersture()
        setRecordSlider()
        setCornerRadius(selectedView: playRecordBgView)
    }
    
    func setGersture(){
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playPressed))
        playRecordIcon.addGestureRecognizer(playTap)
        
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deletePressed))
        deleteRecordIcon.addGestureRecognizer(deleteTap)
    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    @objc func playPressed(){
        if playRecordIcon.image != UIImage(named: "pause"){
            print("play")
            playRecordIcon.image = UIImage(named: "pause")
            runProdTimer()
            delegate.playRecord()
        }else{
            print("pause")
            playRecordIcon.image = UIImage(named: "play")
            delegate.pauseRecord()
            timer.invalidate()
        }
    }
    
    @objc func deletePressed(){
        delegate.deleteRecord()
    }
    
    func setRecordSlider(){
        recordSlider.isUserInteractionEnabled = false
        recordSlider.minimumValue = 0
        recordSlider.maximumValue = Float(totalTimeCount)
        recordSlider.value = Float(recordValue)
        recordSlider.setThumbImage(UIImage(named: "grey"), for: .normal)
    }
    
    @objc func finishPlaying(){
        timer.invalidate()
        playRecordIcon.image = UIImage(named: "play")
        recordSlider.value = 0
        recordValue = 0
        recordSlider.setThumbImage(UIImage(named: "grey"), for: .normal)
        playingTimerLbl.isHidden = true
        viewedTimeCount = totalTimeCount
    }
    
    func runProdTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: (#selector(updateProdTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateProdTimer() {
        viewedTimeCount -= 0.25
        recordValue += 0.25
        
        print("total count: \(totalTimeCount) viewdTimeCont: \(viewedTimeCount) recordValue : \(recordValue)")
        
        if recordValue <= totalTimeCount{
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.recordSlider.value = Float(self.recordValue)
            })
        }
        
        if viewedTimeCount < 0{
            timer.invalidate()
            playRecordIcon.image = UIImage(named: "play")
            recordSlider.value = 0
            recordValue = 0
            playingTimerLbl.isHidden = true
            recordSlider.setThumbImage(UIImage(named: "grey"), for: .normal)
//            delegate.pauseRecord()
            viewedTimeCount = totalTimeCount
        }else{
            recordSlider.setThumbImage(UIImage(named: "red"), for: .normal)
            playingTimerLbl.isHidden = false
            playingTimerLbl.text = "-\(prodTimeString(time: TimeInterval(exactly: self.viewedTimeCount)!))"
        }
    }
    
    func prodTimeString(time: TimeInterval) -> String {
        let prodMinutes = Int(time) / 60 % 60
        let prodSeconds = Int(time) % 60
        
        return String(format: "%02d:%02d", prodMinutes, prodSeconds)
    }
    
    @objc func showProgressLoading(){
        uploadingProgressView.startAnimating()
    }
    
    @objc func hideProgressLoading(){
        uploadingProgressView.stopAnimating()
        deleteRecordIcon.isHidden = false
    }
}
