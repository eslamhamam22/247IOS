//
//  RequestFromStorePresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/24/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class RequestFromStorePresenter : Presenter{
    
    var view : RequestFromStoreView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    var infoRepository: InfoRepository!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var isSubmitAndUpload = false
    
    init (repository: OrderRepository, userRepository: UserRepository, infoRepository: InfoRepository) {
        orderRepository = repository
        self.userRepository = userRepository
        self.infoRepository = infoRepository
    }
    
    func setView(view: RequestFromStoreView) {
        weak var weakView = view
        self.view = weakView
    }
       
    func requestOrder(desc: String,fromType: Int, fromLat: Double, fromLng: Double, toLat: Double, toLng: Double, fromAddress: String, toAddress: String, storeName: String, images: String, voicenoteId: Int, deliveryDuration: Int, couponCode: String){
        
        self.view?.showloading()
        orderRepository.requestOrder(desc: desc, fromType: fromType, fromLat: fromLat, fromLng: fromLng, toLat: toLat, toLng: toLng, fromAddress: fromAddress, toAddress: toAddress, storeName: storeName, images: images, voicenoteId: voicenoteId, is_reorder: false, deliveryDuration: deliveryDuration, couponCode: couponCode) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.navigateToOrderDetails(order: (result?.data?.order)!)
                    }else{
                        self.view?.showSuccess()
                    }
                }else{
                    self.view?.showSuccess()
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showBlockedArea()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.couponCode != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.couponCode)!)
                        self.view?.removeCouponCode()
                    }else if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                    
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.blockedArea{
                if result?.error != nil{
                    if result?.error?.couponCode != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.couponCode)!)
                        self.view?.removeCouponCode()
                    }else if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }else{
                        self.view?.showGeneralError()
                    }
                }else{
                    self.view?.showGeneralError()
                }
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func uploadRecord(recordData: Data, isSubmitAndUpload: Bool){
        if isSubmitAndUpload{
            self.view?.showloading()
        }else{
            self.view?.showAudioloading()
        }
        orderRepository.uploadRecord(recordData: recordData) { (result, error) in
            if isSubmitAndUpload{
                self.view?.hideLoading()
            }else{
                self.view?.hideAudioLoading()
            }
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.showUploadAudioSuccess(data: (result?.data)!)
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
                self.view?.showUploadAudioFailure()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
                self.view?.showUploadAudioFailure()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
                self.view?.showUploadAudioFailure()
            }else{
                self.view?.showNetworkError()
                self.view?.showUploadAudioFailure()
            }
        }
    }
    
    func deleteRecord(id: Int){
        
        orderRepository.deleteRecord(id: id) { (result, error) in
            
        }
    }
    
    func uploadImage(imageFile: UIImage?){
        self.view?.showloading()
        orderRepository.uploadImage(imageFile: imageFile) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setImage(image: (result?.data)!)
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func deleteImage(id: Int){
        self.view?.showloading()
        orderRepository.deleteImage(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                self.view?.successDelete(id: id)
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func getPrayerTimes(){
        self.view?.showloading()
        infoRepository.getPrayerTimes { (result, error) in
            self.view?.hideLoading()
            if error == NetworkInfoRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setPrayerTimes(times: (result?.data)!)
                }
            }else if error == NetworkInfoRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkInfoRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol RequestFromStoreView : class {
    
    func showloading()
    func hideLoading()
    func showAudioloading()
    func hideAudioLoading()
    func showNetworkError()
    func showGeneralError()
    func showSuccess()
    func navigateToOrderDetails(order: Order)
    func showUploadAudioFailure()
    func showUploadAudioSuccess(data: AudioRecorderData)
    func showSusspendedMsg(msg : String)
    func setImage(image: DelegateImageData)
    func successDelete(id: Int)
    func showBlockedArea()
    func setPrayerTimes(times: PrayerTimes)
    func removeCouponCode()

}

