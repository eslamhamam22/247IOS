//
//  BalanceOptionsPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/15/20.
//  Copyright © 2020 Objects. All rights reserved.
//

import Foundation
import UIKit

class BalanceOptionsPresenter : Presenter{
    
    var view : BalanceOptionsView?
    var walletRepository: WalletRepository!
    var userRepository: UserRepository!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
   
    
    init (walletRepository: WalletRepository , userRepository: UserRepository) {
        self.walletRepository = walletRepository
        self.userRepository = userRepository
    }
    
    func setView(view: BalanceOptionsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    
    func getcheckoutId(amount: Double){
        self.view?.showLoading()
        walletRepository.getPaymentCheckoutID(amount: amount) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkWalletRepository.ErrorType.none{
                if result?.data != nil{
                    print("checkout_id \(result?.data!.checkout_id ?? "")")
                    //self.view?.presentCheckoutUI(paymentData: (result?.data!)!)
                    self.view?.showPaymentInfoForum(paymentData: (result?.data!)!)
                }
                
            }else if error == NetworkWalletRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkWalletRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
            }else if error == NetworkWalletRepository.ErrorType.suspended{
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
    
    func didLoad() {}
    
    func didAppear() {}
    
}

protocol BalanceOptionsView : class {
    func showLoading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func presentCheckoutUI(paymentData : PaymentData)
    func showPaymentInfoForum(paymentData : PaymentData)

}

