//
//  CurrentOrdersPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class CurrentOrdersPresenter : Presenter{
    
    var view : CurrentOrdersView?
    var userRepository: UserRepository!
    var delegateRepository: DelegateRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var page = 2
    var limit = 10
    var orders = [Order]()

    
    init (repository: DelegateRepository, userRepository: UserRepository) {
        delegateRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: CurrentOrdersView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func setData(orders : [Order]){
        self.orders = orders
    }
    
    func resetData(){
        self.page = 1
        self.orders.removeAll()
    }
    
    func getUserCurrentOrders(){
        if self.page == 1{
            self.view?.showloading()
        }
        userRepository.getUserCurrentOrders(page: page,  limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if( result?.data!.count == 0 && self.orders.count == 0) {
                    self.view?.stopInfinitScroll()
                } else if (self.orders.count > 0 && result?.data!.count == 0  ) {
                    self.view?.stopInfinitScroll()
                }else {
                    self.orders.append(contentsOf: result!.data!)
                    self.page = self.page+1
                    self.view?.setOrders(orders: self.orders)
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
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
    
    
    func getDelegateCurrentOrders(){
        if self.page == 1{
            self.view?.showloading()
        }
        delegateRepository.getDelegateCurrentOrders(page: page,  limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                if( result?.data!.count == 0 && self.orders.count == 0) {
                    self.view?.stopInfinitScroll()
                } else if (self.orders.count > 0 && result?.data!.count == 0  ) {
                    self.view?.stopInfinitScroll()
                }else {
                    self.orders.append(contentsOf: result!.data!)
                    self.page = self.page+1
                    self.view?.setOrders(orders: self.orders)
                }
            }else if error == NetworkDelegateRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.auth{
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

protocol CurrentOrdersView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func stopInfinitScroll()
    func setOrders(orders : [Order])
    
}
