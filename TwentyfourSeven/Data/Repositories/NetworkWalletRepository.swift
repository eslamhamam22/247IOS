//
//  NetworkWalletRepository.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class NetworkWalletRepository : WalletRepository {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    
    // 401 for refresh token ... 403 suspended (blocked) user
    enum ErrorType {
        case none
        case auth
        case suspended
        case network
        case invalidValue
        case serverError
        case generalError
        case TimeError
        case controlError
    }
    
    func getBankAccounts( completionHandler: @escaping (_ resultData : BankAccountsResponse?, _ error : NetworkWalletRepository.ErrorType) -> ()) {
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.BANK_ACCOUNTS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.BANK_ACCOUNTS)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
      
        
        Alamofire.request(url, method: .get, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let bankAccountsResponse = BankAccountsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(bankAccountsResponse, NetworkWalletRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(bankAccountsResponse, NetworkWalletRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(bankAccountsResponse, NetworkWalletRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }

                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func performBankTransfer(amount : Double , imageFile : UIImage , bankAccount : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkWalletRepository.ErrorType) -> ()){
        
        var url = ""
        
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)/\(APIURLs.BANK_TRANSFER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)/\(APIURLs.BANK_TRANSFER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let parameters = ["amount" : amount , "bankAccount" : bankAccount] as [String : Any]
        
        
        let URL = try! URLRequest(url: url, method: .post, headers : headers)
        Alamofire.upload(multipartFormData: {
            
            (multipartFormData) in
            
            if let imageData = imageFile.jpegData(compressionQuality: 0.6) {
                multipartFormData.append(imageData, withName: "imageFile", fileName: "pp.jpg", mimeType: "image/jpg")
            }
            for (key, value) in parameters {
                let strValue = "\(value)"
                multipartFormData.append(strValue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
        }, with: URL, encodingCompletion: {
            (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(_):
                        print(response.description)
                        let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                        let statusCode = response.response?.statusCode
                        if(statusCode == 200){
                            completionHandler(basicResponse, NetworkWalletRepository.ErrorType.none)
                        }else if statusCode == 422{
                            if basicResponse.error != nil{
                                basicResponse.error?.defaultError =                         self.handleError(response: response.result.value!)
                            }
                            completionHandler(basicResponse, NetworkWalletRepository.ErrorType.invalidValue)                        }else if statusCode == 401{
                            completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                        }else if statusCode == 403{
                            if basicResponse.error != nil{
                                basicResponse.error?.defaultError =                         self.handleError(response: response.result.value!)
                            }
                            completionHandler(basicResponse, NetworkWalletRepository.ErrorType.suspended)
                        }else if statusCode == 409{
                            if basicResponse.error != nil{
                                basicResponse.error?.defaultError =                         self.handleError(response: response.result.value!)
                            }
                            completionHandler(basicResponse, NetworkWalletRepository.ErrorType.controlError)
                        }else if (statusCode == 500 || statusCode == 503) {
                            completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                        }else if Utils.isConnectedToNetwork(){
                            completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                        }else{
                            completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                        }

                    case .failure(_):
                        let statusCode = response.response?.statusCode
                        print(response.description)
                        if statusCode == 422{
                            completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                        }else if statusCode == 400 || statusCode == 401{
                            completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                        }else if (statusCode == 500 || statusCode == 503) {
                            completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                        }else if Utils.isConnectedToNetwork(){
                            completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                        }else{
                            completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                        }
                    }
                    
                }
            case .failure(_):
                print("failure")
                completionHandler(nil, NetworkWalletRepository.ErrorType.network)
            }
        })
    }
    
    func getTransactions(page : Int , limit : Int ,completionHandler: @escaping (_ resultData : TransactionListResponse?, _ error : NetworkWalletRepository.ErrorType) -> () ){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)/\(APIURLs.GET_TRANSACTIONS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)/\(APIURLs.GET_TRANSACTIONS)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let parameters = ["page" : page,
                          "limit" : limit]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let transactionListResponse = TransactionListResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(transactionListResponse, NetworkWalletRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(transactionListResponse, NetworkWalletRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(transactionListResponse, NetworkWalletRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                }
        }
    }
    
     func getWalletDetails(completionHandler: @escaping (_ resultData : DelegateWalletResponse?, _ error : NetworkWalletRepository.ErrorType) -> ()){
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)/\(APIURLs.DELEGATE_WALLET)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)/\(APIURLs.DELEGATE_WALLET)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        
        Alamofire.request(url, method: .get, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let delegateWalletResponse = DelegateWalletResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(delegateWalletResponse, NetworkWalletRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(delegateWalletResponse, NetworkWalletRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(delegateWalletResponse, NetworkWalletRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getPaymentCheckoutID(amount: Double, completionHandler: @escaping (_ resultData : PaymentDataResponse?, _ error : NetworkWalletRepository.ErrorType) -> ()){
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PAYMENT_REGISTER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PAYMENT_REGISTER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let parameters = ["amount" : amount]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let paymentDataResponse = PaymentDataResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(paymentDataResponse, NetworkWalletRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(paymentDataResponse, NetworkWalletRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(paymentDataResponse, NetworkWalletRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkWalletRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkWalletRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkWalletRepository.ErrorType.network)
                    }
                }
        }
    }

    func handleError(response: Any) -> String{
        if let error = response as? Dictionary<String, Any>{
            if let errorBody = error.valueForKeyPath(keyPath: "error") as? Dictionary<String, Any>{
                if let firstValue = errorBody.first?.value {
                    print(firstValue)
                    return "\(firstValue)"
                }
            }
        }
        return ""
    }
}
