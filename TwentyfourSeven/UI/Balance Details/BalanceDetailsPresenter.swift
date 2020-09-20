//
//  BalanceDetailsPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class BalanceDetailsPresenter : Presenter{
    
    var view : BalanceDetailsView?
    var walletRepository: WalletRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var page = 1
    var limit = 10
    var transactions = [Transaction]()
    var wallet = DelegateWalletInfo()
    
    init (userRepository: UserRepository, walletRepository: WalletRepository) {
        self.userRepository = userRepository
        self.walletRepository = walletRepository
    }
    
    func setView(view: BalanceDetailsView) {
        weak var weakView = view
        self.view = weakView
        getWalletDetails()
    }
    
    func getWalletDetails(){
        
        self.view?.showloading()
        self.walletRepository.getWalletDetails(){ (result, error) in
            self.view?.hideLoading()
            if error == NetworkWalletRepository.ErrorType.none{
                if (result?.data) != nil{
                    self.wallet = (result?.data)!
                }
                self.getTransactionsList()
            }else if error == NetworkWalletRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkWalletRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
            }else if error == NetworkWalletRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkWalletRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkWalletRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkWalletRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func getTransactionsList(){
        if page == 1{
            self.view?.showloading()
        }
        self.walletRepository.getTransactions(page: page, limit: limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkWalletRepository.ErrorType.none{
                if( result?.data?.count == 0 && self.transactions.count == 0) {
                    self.view?.showNoData(delegateWallet: self.wallet)
                } else if (self.transactions.count > 0 && result?.data?.count == 0  ) {
                    self.view?.stopInfinitScroll()
                }else {
                    self.transactions.append(contentsOf: result!.data!)
                    self.page = self.page+1
                    self.view?.setTransactions(transactions: self.transactions, delegateWallet: self.wallet)
                }
            }else if error == NetworkWalletRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkWalletRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
            }else if error == NetworkWalletRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkWalletRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkWalletRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkWalletRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    
    func resetData(){
        self.page = 1
        self.transactions.removeAll()
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol BalanceDetailsView : class {
    func showloading()
    func hideLoading()
    func showNoData(delegateWallet : DelegateWalletInfo)
    func stopInfinitScroll()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setTransactions(transactions : [Transaction] , delegateWallet : DelegateWalletInfo)
}

