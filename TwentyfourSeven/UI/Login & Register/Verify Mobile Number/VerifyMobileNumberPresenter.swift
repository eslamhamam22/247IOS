//
//  VerifyMobileNumberPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/9/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class VerifyMobileNumberPresenter : Presenter{
    
    var view : VerifyMobileNumberView?
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: UserRepository) {
        userRepository = repository
    }
    
    func setView(view: VerifyMobileNumberView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func verifyMobileNumber(mobileNumber: String, code: String, socialToken: String, isFacebook: Bool){
        self.view?.showloading()
        userRepository.verifyCode(mobileNumber: mobileNumber, code: code, socialToken: socialToken, isFacebook: isFacebook) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if self.userDefault.getPlayerID() != nil && (result?.data)!.token  != nil && self.appDelegate.isNotificationAllowed{
                    //Register for push notification
                    self.registerForPushNotification(data: (result?.data)!, token: (result?.data)!.token!)
                   // self.view?.showSuccess(data: (result?.data)!)

                }else if self.userDefault.getPlayerID() == nil && self.appDelegate.isNotificationAllowed{
                    //don't have player id and allow notifications permission
                    self.view?.showGeneralError()
                   // self.view?.showSuccess(data: (result?.data)!)

                }else{
                    self.view?.showSuccess(data: (result?.data)!)
                }
                
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showInavlidCode()
            }else if error == NetworkUserRepository.ErrorType.suspended{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func updateVerifyMobileNumber(mobileNumber: String, code: String){
        self.view?.showloading()
        userRepository.updateVerifyCode(mobileNumber: mobileNumber, code: code) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.showSuccess(data: (result?.data)!)
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showInavlidCode()
            }else if error == NetworkUserRepository.ErrorType.suspended{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func sendVerificationMsg(mobileNumber : String) {
        self.view?.showloading()
        userRepository.requestCode(mobileNumber: mobileNumber) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.showSentCodeSuccess()
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
//                self.view?.showPhoneError()
                if result?.error != nil{
                    if result?.error?.mobile != nil{
                        self.view?.showTimeError(msg: (result?.error?.mobile)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.TimeError{
                if result?.error != nil{
                    if result?.error?.mobile != nil{
                        self.view?.showTimeError(msg: (result?.error?.mobile)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.suspended{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg:  (result?.error?.defaultError)!)
                    }
                }
//                self.view?.showSusspendedMsg(msg: "suspended".localized())

            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func updateRequestCode(mobileNumber : String) {
        self.view?.showloading()
        userRepository.updateRequestCode(mobileNumber: mobileNumber) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.showSentCodeSuccess()
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
//                self.view?.showPhoneError()
                if result?.error != nil{
                    if result?.error?.mobile != nil{
                        self.view?.showTimeError(msg: (result?.error?.mobile)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.TimeError{
                if result?.error != nil{
                    if result?.error?.mobile != nil{
                        self.view?.showTimeError(msg: (result?.error?.mobile)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.suspended{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg:  (result?.error?.defaultError)!)
                    }
                }
//                self.view?.showSusspendedMsg(msg: "suspended".localized())

            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func refreshToken(){
        self.view?.showloading()
        userRepository.refreshToken(refreshToken: userDefault.getRefreshToken()!) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.showSuccessRefreshToken(data: (result?.data)!)
                }else{
                    self.view?.showSuccessRefreshToken(data: VerifyCodeData())
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func registerForPushNotification(data: VerifyCodeData , token : String){
        self.view?.showloading()
        let playerId = userDefault.getPlayerID()!
        userRepository.registerForPushNotification(playedId: playerId, token: token) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.showSuccess(data : data)
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkUserRepository.ErrorType.suspended{
                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
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

protocol VerifyMobileNumberView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showInavlidCode()
    func showGeneralError()
    func showSentCodeSuccess()
    func showPhoneError()
    func showSuccess(data: VerifyCodeData)
    func showTimeError(msg : String)
    func showSuccessRefreshToken(data : VerifyCodeData)
    func showSusspendedMsg(msg : String)
}


