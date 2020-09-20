//
//  WalletRepository.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit


protocol WalletRepository {
    
    func getBankAccounts( completionHandler: @escaping (_ resultData : BankAccountsResponse?, _ error : NetworkWalletRepository.ErrorType) -> ())
    
    func performBankTransfer(amount : Double , imageFile : UIImage , bankAccount : Int , completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkWalletRepository.ErrorType) -> ())
    
    func getTransactions(page : Int , limit : Int ,completionHandler: @escaping (_ resultData : TransactionListResponse?, _ error : NetworkWalletRepository.ErrorType) -> () )
    
    func getWalletDetails(completionHandler: @escaping (_ resultData : DelegateWalletResponse?, _ error : NetworkWalletRepository.ErrorType) -> ())
    
    func getPaymentCheckoutID(amount: Double, completionHandler: @escaping (_ resultData : PaymentDataResponse?, _ error : NetworkWalletRepository.ErrorType) -> ())

}
