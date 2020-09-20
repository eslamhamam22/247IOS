//
//  CarDetailsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/8/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class CarDetailsPresenter : Presenter{
    
    var view : CarDetailsView?
    var delegateRepository: DelegateRepository!
    var userRepository: UserRepository!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: DelegateRepository, userRepository: UserRepository!) {
        delegateRepository = repository
        self.userRepository = userRepository
        
    }
    
    func setView(view: CarDetailsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getCarDetails(){
        self.view?.showloading()
        delegateRepository.getCarDetails { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setData(data: (result?.data)!)
                }
            }else if error == NetworkDelegateRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkDelegateRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkDelegateRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkDelegateRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.generalError{
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

protocol CarDetailsView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setData(data: CarDetailsData)
}



