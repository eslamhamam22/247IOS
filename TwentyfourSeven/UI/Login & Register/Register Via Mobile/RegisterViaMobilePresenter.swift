//
//  RegisterViaMobilePresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/9/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class RegisterViaMobilePresenter : Presenter{
    
    var view : RegisterViaMobileView?
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var isPhone = false
    
    init (repository: UserRepository) {
        userRepository = repository
    }
    
    func setView(view: RegisterViaMobileView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func sendVerificationMsg(mobileNumber : String, countryCode : String) {
        let userMobile = countryCode + mobileNumber
        self.view?.showloading()
        userRepository.requestCode(mobileNumber: userMobile) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.navigateToVerify()
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
    
    func updateRequestCode(mobileNumber : String, countryCode : String) {
        let userMobile = countryCode + mobileNumber
        self.view?.showloading()
        userRepository.updateRequestCode(mobileNumber: userMobile) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.navigateToVerify()
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
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol RegisterViaMobileView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showEmptyMobileNumber()
    func showPhoneError()
    func navigateToVerify()
    func showTimeError(msg : String)
    func showSusspendedMsg(msg : String)
}


