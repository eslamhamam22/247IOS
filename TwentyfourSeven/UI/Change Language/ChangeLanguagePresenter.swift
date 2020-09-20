//
//  ChangeLanguagePresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/17/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class ChangeLanguagePresenter : Presenter{
    
    var view : ChangeLanguageView?
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: UserRepository) {
        userRepository = repository
    }
    
    func setView(view: ChangeLanguageView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func changeLanguage(language : String){
        userRepository.changeLanguage(language: language) { (result, error) in
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    self.userDefault.setUserData(userData: (result?.data)!)
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showValidationError()
            }else if error == NetworkUserRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkUserRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.controlError{
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

protocol ChangeLanguageView : class {
    func showNetworkError()
    func showGeneralError()
    func showValidationError()
    func showSusspendedMsg(msg : String)
}


