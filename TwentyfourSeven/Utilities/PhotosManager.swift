//
//  PhotosManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/6/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import AVFoundation
import Photos

class PhotosManager:NSObject  , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    let imagePicker = UIImagePickerController()
    var imageFile: UIImage!
    var imageType : ImageFormat?
    var mimeType = "png"
    var result = ""
    var tabBarBtnAction : Bool?
    
    override init() {
        super.init()
        imagePicker.delegate = self

    }
    
    
    func loadPrescriptionPic(tabBarBtnAction : Bool) {
        self.tabBarBtnAction = tabBarBtnAction
        let alert:UIAlertController=UIAlertController(title: "choosePhoto".localized(), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title:"camera".localized(), style:
            .default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let gallaryAction = UIAlertAction(title: "gallery".localized(), style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.topMostController().present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // addImage.contentMode = .scaleToFill
                self.imageFile = pickedImage
                var imgData: NSData = NSData(data: pickedImage.jpegData(compressionQuality: 1)!)
                var imageSize: Int = imgData.length
                if #available(iOS 10.0, *) {
                    self.imageFile = self.imageFile.fixOrientation()
                }
                self.imageFile = self.resizeImage(image: self.imageFile)
                
                imgData = NSData(data: self.imageFile.jpegData(compressionQuality: 1)!)
                imageSize = imgData.length
                self.imageType =  imgData.imageFormat
                if(self.imageType == .PNG)
                {
                    self.mimeType = "png"
                }else if (self.imageType == .JPEG)
                {
                    self.mimeType = "jpeg"
                }
                
                if(self.imageType == .Unknown) {
                    DispatchQueue.main.async {
                        self.topMostController().dismiss(animated: true, completion: nil)
                        //self.view.makeToast("imageTypeError".localized(), duration: 3.0, position: .bottom)
                        self.result = "imageTypeError"
                        self.imageFile = nil
                        self.navigateToMainScreen()
                    }
                }else{
                    let size = Double(imageSize) / ( 1024.0 * 1024.0)
                    print("image size ", size)
                    if(size > 20) {
                        DispatchQueue.main.async {
                            self.topMostController().dismiss(animated: true, completion: nil)
                            //self.view.makeToast("imageSizeError".localized(), duration: 3.0, position: .bottom)
                            self.result = "imageSizeError"
                            self.imageFile = nil
                            self.navigateToMainScreen()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imagePicker.dismiss(animated: false, completion: {
                                //
                                self.result = "noError"
                                self.navigateToMainScreen()
                            })
                        }
                    }
                }
            }
       
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
            openCameraAction()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                    self.openCameraAction()
                } else {
                    print("Permission denied")
                    self.presentCameraSettings()
                }
            }
        }
    }
    
    func checkPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
        //handle authorized status
            openGallaryAction()
        case .denied, .restricted :
        //handle denied status
            presentGallerySettings()
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                // as above
                    self.openGallaryAction()
                case .denied, .restricted:
                // as above
                    self.presentGallerySettings()
                case .notDetermined:
                    print("notDetermined")
                }
            }
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "",
                                                message: "cameraAccessDenied".localized(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "editCancel".localized(), style: .default))
        alertController.addAction(UIAlertAction(title: "settings".localized(), style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        DispatchQueue.main.async {
            self.topMostController().present(alertController, animated: true)
        }
    }
    
    func presentGallerySettings() {
        let alertController = UIAlertController(title: "",
                                                message: "photosAccessDenied".localized(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "editCancel".localized(), style: .default))
        alertController.addAction(UIAlertAction(title: "settings".localized(), style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        DispatchQueue.main.async {
            self.topMostController().present(alertController, animated: true)
        }
    }

    func openCamera() {
        checkCameraAccess()
    }
    
    func openCameraAction(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.modalPresentationStyle = .overFullScreen
            DispatchQueue.main.async {
                self.topMostController().present(self.imagePicker, animated: true, completion: nil)
            }
            
        }
    }
    
    func openGallary() {
       
       checkPhotoLibraryAccess()
        //        self.view!.addSubview(imagePicker.view!)
    }
    
    func openGallaryAction() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            self.topMostController().present(self.imagePicker, animated: false, completion: nil)
        }
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let size = image.size
        let widthRatio : CGFloat = 0.6
        let heightRatio : CGFloat = 0.6
//        if #available(iOS 10.0, *) {
//            widthRatio  = 0.3
//            heightRatio  = 0.3
//        }else{
//            widthRatio = 0.1
//            heightRatio = 0.1
//        }
        
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func topMostController() -> UIViewController {
//        DispatchQueue.main.async {
            var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            while ((topController?.presentedViewController) != nil) {
                topController = topController?.presentedViewController
            }
            return topController!
//        }
      
    }
    
    func navigateToMainScreen(){
    
        if let navView = self.topMostController() as?  UINavigationController {
            if let view = navView.topViewController as? EditProfileVC{
                print("It's an AnyObject: EditProfileVC")
                view.resultOfCapturingImages(result: self.result, imageFile: self.imageFile, mimeType: mimeType)
            }else  if let view = navView.topViewController as? BecomeADelegateVC{
                print("It's an AnyObject: BecomeADelegateVC")
                view.resultOfCapturingImages(result: self.result, imageFile: self.imageFile, mimeType: mimeType)
            }else  if let view = navView.topViewController as? RequestFromStoreVC{
                print("It's an AnyObject: RequestFromStoreVC")
                view.resultOfCapturingImages(result: self.result, imageFile: self.imageFile, mimeType: mimeType)
            }else  if let view = navView.topViewController as? ChatVC{
                print("It's an AnyObject: ChatVC")
                view.resultOfCapturingImages(result: self.result, imageFile: self.imageFile, mimeType: mimeType)
            }else  if let view = navView.topViewController as? BankTransferRequestVC{
                print("It's an AnyObject: ChatVC")
                view.resultOfCapturingImages(result: self.result, imageFile: self.imageFile, mimeType: mimeType)
            }else{
                print("It's not an edit AnyObject.")

            }
            
        }else {
            print("It's not an nav AnyObject.")
        }
    

    }
    
    
}
