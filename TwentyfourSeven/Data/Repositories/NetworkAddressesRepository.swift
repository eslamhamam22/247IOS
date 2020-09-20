//
//  NetworkAddressesRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class NetworkAddressesRepository: AddressesRepository {
   
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loginPresenter: LoginPresenter!
    let userDefault = UserDefault()
    
    enum ErrorType {
        case none
        case auth
        case suspended
        case network
        case invalidValue
        case serverError
        case generalError
        case controlError
    }
    
    func getAddresses(completionHandler: @escaping (MyAddressesResponse?, NetworkAddressesRepository.ErrorType) -> ()) {
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ADDRESSES)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ADDRESSES)"
        }
        let headers = ["Authorization" : userDefault.getToken()!]
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let addressesResponse = MyAddressesResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(addressesResponse, NetworkAddressesRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(addressesResponse, NetworkAddressesRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(addressesResponse, NetworkAddressesRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func deleteAddress(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkAddressesRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ADDRESSES)/\(id)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ADDRESSES)/\(id)"
        }
        let headers = ["Authorization" : userDefault.getToken()!]
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .delete, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let baseResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(baseResponse, NetworkAddressesRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(baseResponse, NetworkAddressesRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(baseResponse, NetworkAddressesRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func addAddress(title: String,address: String, lat: Double, lng: Double, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkAddressesRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ADDRESSES)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ADDRESSES)"
        }
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let parameters = ["addressTitle" : title,
                          "address" : address,
                          "lat" : lat,
                          "lng" : lng] as [String : Any]
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        print(parameters.description)
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let baseResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(baseResponse, NetworkAddressesRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(baseResponse, NetworkAddressesRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(baseResponse, NetworkAddressesRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkAddressesRepository.ErrorType.network)
                    }
                }
        }
    }
}

