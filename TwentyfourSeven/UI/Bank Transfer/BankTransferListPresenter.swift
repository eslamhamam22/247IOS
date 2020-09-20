//
//  BankTransferListPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class BankTransferListPresenter : Presenter{
    
    var view : BankTransferListView?
    var walletRepository: WalletRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (userRepository: UserRepository, walletRepository: WalletRepository) {
        self.userRepository = userRepository
        self.walletRepository = walletRepository
    }
    
    func setView(view: BankTransferListView) {
        weak var weakView = view
        self.view = weakView
        self.getBankAccounts()
    }
    
    func getBankAccounts(){
        self.view?.showloading()
        self.walletRepository.getBankAccounts { (result, error) in
            self.view?.hideLoading()
            if error == NetworkWalletRepository.ErrorType.none{
                self.view?.gotData(accounts: result?.data ?? [BankAccount]())
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
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol BankTransferListView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func gotData(accounts : [BankAccount])
}
