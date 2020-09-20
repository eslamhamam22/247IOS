//
//  AddCouponPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 5/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class AddCouponPresenter : Presenter{
    
    var view : AddCouponView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: AddCouponView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func validateCoupon(code: String){
        self.view?.showloading()
        orderRepository.validateCoupon(code: code) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                self.view?.showSuccess()
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showFailure()
                if result?.error != nil{
                    if result?.error?.code != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.code)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.view?.showFailure()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
                //                self.userDefault.removeSession()
                self.view?.showFailure()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                self.view?.showFailure()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showFailure()
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showFailure()
                self.view?.showGeneralError()
            }else{
                self.view?.showFailure()
                self.view?.showNetworkError()
            }
        }
    }
  
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol AddCouponView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func showSuccess()
    func showFailure()
}
