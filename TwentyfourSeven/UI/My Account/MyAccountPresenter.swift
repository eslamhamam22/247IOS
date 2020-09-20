//
//  MyAccountPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 1/10/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class MyAccountPresenter : Presenter{
    
    var view : MyAccountView?
    var userRepository: UserRepository!
    var userDefault = UserDefault()
    
    init (repository: UserRepository) {
        userRepository = repository
    }
    
    func setView(view: MyAccountView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func unRegisterPushNotifications(){
        self.view?.showloading()
        self.userRepository.unregisterForPushNotification { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.unRegisterSuccessfully()
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
//                self.userDefault.removeSession()
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

protocol MyAccountView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func unRegisterSuccessfully()
  
}
