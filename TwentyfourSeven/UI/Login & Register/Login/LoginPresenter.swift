//
//  LoginPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 11/29/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

class LoginPresenter : Presenter{
    
    var view : LoginView?
    var loginRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var userToken = ""
    var isPhone = false
    
    init (repository: UserRepository) {
        loginRepository = repository
    }
    
    func setView(view: LoginView) {
        weak var weakView = view
        self.view = weakView
    }
    
    
    func LoginWithFacebook(_ viewController: UIViewController)
    {
        self.view?.showloading()
        loginRepository.loginWithFacebook(viewController) { (token, error) in
            if(error == NetworkUserRepository.ErrorType.none) {
                self.sendFacebookToken(token: token)
                print("fb token: \(token)")
            } else if (error == NetworkUserRepository.ErrorType.serverError){
                self.view?.hideLoading()
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
                self.view?.hideLoading()
                self.view?.showGeneralError()
            }else{
                self.view?.hideLoading()
                self.view?.showNetworkError()
            }
        }
    }


    func sendFacebookToken(token : String)
    {
        loginRepository.socialLogin(isFacebook: true, token: token) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.registeredBefore != nil{
                        if (result?.data)!.token != nil{
                            let token  = "Bearer " + (result?.data)!.token!
                            self.userDefault.setToken(token)
                        }
                        if self.userDefault.getPlayerID() != nil && self.userDefault.getToken() != nil && self.appDelegate.isNotificationAllowed{
                            self.registerForPushNotification(isRegisteredBefore: (result?.data?.registeredBefore)!, token: token, isFacebook: true, data: (result?.data)!)
                        }else{
                            self.view?.showSuccess(isRegisteredBefore: (result?.data?.registeredBefore)!, token: token, isFacebook: true, data: (result?.data)!)
                        }
                        
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showInavlidToken()
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
    
    func LoginWithGoogle()
    {
        self.view?.showloading()
        loginRepository.loginWithGoogle(self)
    }
    
    func sendGoogleToken(token: String) {
        print("tokennn \(token)")
        loginRepository.socialLogin(isFacebook: false, token: token) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    if (result?.data)!.token != nil{
                        let token  = "Bearer " + (result?.data)!.token!
                        self.userDefault.setToken(token)
                    }
                    if self.userDefault.getPlayerID() != nil && self.userDefault.getToken() != nil && self.appDelegate.isNotificationAllowed{
                        self.registerForPushNotification(isRegisteredBefore: (result?.data?.registeredBefore)!, token: token, isFacebook: true, data: (result?.data)!)
                    }else{
                        self.view?.showSuccess(isRegisteredBefore: (result?.data?.registeredBefore)!, token: token, isFacebook: false, data: (result?.data)!)
                    }
                    
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showInavlidToken()
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
    
    func registerForPushNotification(isRegisteredBefore : Bool, token: String, isFacebook: Bool, data : VerifyCodeData){
        self.view?.showloading()
        loginRepository.registerForPushNotification(playedId: userDefault.getPlayerID()!, token: nil) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.showSuccess(isRegisteredBefore: isRegisteredBefore, token: token, isFacebook: isFacebook, data: data)
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.loginRepository.generalRefreshToken()
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
    
    
    func unregisterPlayerId(){
        loginRepository.unregisterPlayerId { (result, error) in
            if error == NetworkUserRepository.ErrorType.none{
                print("success unregistPlayerId")
            }else{
                print("fail unregistPlayerId")
            }
        }
    }
    
    func didLoad() {
        
    }
    
    
    func didAppear() {
       
    }
    
}

protocol LoginView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showInavlidToken()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func showSuccess(isRegisteredBefore : Bool, token: String, isFacebook: Bool, data : VerifyCodeData)
}


