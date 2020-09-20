//
//  RatePresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class RatePresenter : Presenter{
    
    var view : RateView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: RateView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func rateCustomer(orderId: Int, rating: Int, comment: String){
        self.view?.showloading()
        orderRepository.addRate(orderId: orderId, rating: rating, comment: comment, isUserRateDelegate: false) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.showSuccess(order: (result?.data?.order)!)
                    }
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
    
    func rateDelegate(orderId: Int, rating: Int, comment: String){
        self.view?.showloading()
        orderRepository.addRate(orderId: orderId, rating: rating, comment: comment, isUserRateDelegate: true) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.showSuccess(order: (result?.data?.order)!)
                    }
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
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol RateView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func showSuccess(order: Order)
}
