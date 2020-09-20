//
//  MyOrderPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class MyOrdersPresenter : Presenter{
    
    var view : MyOrdersView?
    var userRepository: UserRepository!
    var delegateRepository: DelegateRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var userHistoryPage = 1
    var delegateHistoryPage = 1

    var limit = 10
    var userCurrentOrders = [Order]()
    var userPastOrders = [Order]()

    var delegateCurrentOrders = [Order]()
    var delegatePastOrders = [Order]()

    init (repository: DelegateRepository, userRepository: UserRepository) {
        delegateRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: MyOrdersView) {
        weak var weakView = view
        self.view = weakView
    }
    func resetData(){
        userHistoryPage = 1
        delegateHistoryPage = 1
        userCurrentOrders.removeAll()
        userPastOrders.removeAll()
        delegateCurrentOrders.removeAll()
        delegatePastOrders.removeAll()
    }
    
    func changeDelegateRequestsStatus(enable : Bool){
        self.view?.showloading()
        
        self.delegateRepository.enableDelegateRequests(enable : enable) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                self.view?.changeDelegateRequestsStatusSuccessfully(active: result?.data?.active)
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
                self.view?.showChangeRequestsStatusNetworkError()
            }
        }
    }
    
    func getUserCurrentOrders(showLoading : Bool){
        if showLoading{
            self.view?.showloading()
        }
        userRepository.getUserCurrentOrders(page: 1,  limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    self.userCurrentOrders = (result?.data)!
                }
                self.getUserPastOrders(showLoading: showLoading)
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
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    func getUserPastOrders(showLoading : Bool){
     
        if userHistoryPage == 1 && showLoading{
            self.view?.showloading()
        }
        userRepository.getUserPastOrders(page: self.userHistoryPage,  limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if( result?.data!.count == 0 && self.userPastOrders.count == 0) {
                    self.view?.showUserNoData(currentOrders: self.userCurrentOrders, type: "user")
                } else if (self.userPastOrders.count > 0 && result?.data!.count == 0  ) {
                    self.view?.stopInfinitScroll(type : "user")
                }else {
                    self.userPastOrders.append(contentsOf: result!.data!)
                    self.userHistoryPage = self.userHistoryPage+1
                    self.view?.setUserData(currentOrders: self.userCurrentOrders, pastOrders: self.userPastOrders , type: "user")
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
    func getDelegateCurrentOrders(showLoading : Bool){
        
        if showLoading{
            self.view?.showloading()
        }
        
        delegateRepository.getDelegateCurrentOrders(page: 1,  limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                if result?.data != nil{
                    self.delegateCurrentOrders = (result?.data)!
                }
                self.getDelegatePastOrders(showLoading: showLoading)
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
    func getDelegatePastOrders(showLoading : Bool){
       
        if delegateHistoryPage == 1 && showLoading{
            self.view?.showloading()
        }
        
        delegateRepository.getDelegatePastOrders(page: self.delegateHistoryPage,  limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                if( result?.data!.count == 0 && self.delegatePastOrders.count == 0) {
                    self.view?.showDelegateNoData(currentOrders: self.delegateCurrentOrders, type: "delegate")
                }else if (self.delegatePastOrders.count > 0 && result?.data!.count == 0  ) {
                    self.view?.stopInfinitScroll(type : "delegate")
                }else {
                    self.delegatePastOrders.append(contentsOf: result!.data!)
                    self.delegateHistoryPage = self.delegateHistoryPage+1
                    self.view?.setDelegateData(currentOrders: self.delegateCurrentOrders, pastOrders: self.delegatePastOrders , type: "delegate")
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

protocol MyOrdersView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func stopInfinitScroll(type : String)
    func changeDelegateRequestsStatusSuccessfully(active : Bool?)
    func setUserData(currentOrders : [Order] , pastOrders : [Order] , type : String)
    func setDelegateData(currentOrders : [Order] , pastOrders : [Order] , type : String)
    func showDelegateNoData(currentOrders : [Order], type : String)
    func showUserNoData(currentOrders : [Order] , type : String)
    func showChangeRequestsStatusNetworkError()

}
