//
//  BankTransferRequestPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/24/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class BankTransferRequestPresenter : Presenter{
    
    var view : BankTransferRequestView?
    var walletRepository: WalletRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (userRepository: UserRepository, walletRepository: WalletRepository) {
        self.userRepository = userRepository
        self.walletRepository = walletRepository
    }
    
    func setView(view: BankTransferRequestView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func performBankTransfer(amount : Double , imageFile : UIImage , bankId : Int){
        self.view?.showloading()
        self.walletRepository.performBankTransfer(amount: amount, imageFile: imageFile, bankAccount: bankId) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkWalletRepository.ErrorType.none{
                self.view?.transferredSuccessfully()
            }else if error == NetworkWalletRepository.ErrorType.invalidValue{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }else{
                        self.view?.showGeneralError()
                    }
                }else{
                    self.view?.showGeneralError()
                }
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

protocol BankTransferRequestView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func transferredSuccessfully()
}

