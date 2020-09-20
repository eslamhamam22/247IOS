//
//  NetworkDelegateRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class NetworkDelegateRepository: DelegateRepository {
  
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
    
    func uploadDelegateImage(imageFile: UIImage?, type: String, completionHandler: @escaping (UploadDelegateImageResponse?, NetworkDelegateRepository.ErrorType) -> ()) {
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_IMAGE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_IMAGE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let parameters = ["type" : type]

        if(imageFile != nil) {
            let URL = try! URLRequest(url: url, method: .post, headers : headers)
            Alamofire.upload(multipartFormData: {
                
                (multipartFormData) in
                
                if let imageData = imageFile?.jpegData(compressionQuality: 0.6) {
                    multipartFormData.append(imageData, withName: "imageFile", fileName: "pp.jpg", mimeType: "image/jpg")
                }
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
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
                            let uploadDelegateImageResponse = UploadDelegateImageResponse(json: response.result.value! as! JSON)!
                            let statusCode = response.response?.statusCode
                            if(statusCode == 200){
                                completionHandler(uploadDelegateImageResponse, NetworkDelegateRepository.ErrorType.none)
                            }else if statusCode == 422{
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                            }else if statusCode == 401{
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                            }else if statusCode == 403{
                                completionHandler(uploadDelegateImageResponse, NetworkDelegateRepository.ErrorType.suspended)
                            }else if statusCode == 409{
                                completionHandler(uploadDelegateImageResponse, NetworkDelegateRepository.ErrorType.controlError)
                            }else if (statusCode == 500 || statusCode == 503) {
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                            }else if Utils.isConnectedToNetwork(){
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                            }else{
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                            }
                            
                        case .failure(_):
                            let statusCode = response.response?.statusCode
                            print(response.description)
                            if statusCode == 422{
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                            }else if statusCode == 400 || statusCode == 401{
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                            }else if (statusCode == 500 || statusCode == 503) {
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                            }else if Utils.isConnectedToNetwork(){
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                            }else{
                                completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                            }
                        }
                        
                    }
                case .failure(_):
                    print("failure")
                    completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                }
            })
            
        } else {
            completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
        }
    }
    
    func deleteDelegateImage(id : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_IMAGE)/\(String(describing: id))"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_IMAGE)/\(String(describing: id))"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
       
        Alamofire.request(url, method: .delete, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func requestDelegate(carDetails : String,images: String, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_REQUEST)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_REQUEST)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let parameters = ["carDetails" : carDetails,
                          "images" : images]

        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
    
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getCarDetails(completionHandler: @escaping (_ resultData : CarDetailsResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CAR_DETAILS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CAR_DETAILS)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        Alamofire.request(url, method: .get, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let carDetailsResponse = CarDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(carDetailsResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                        
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(carDetailsResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(carDetailsResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func enableDelegateRequests(enable : Bool , completionHandler: @escaping (_ resultData : EnableRequestsResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REQUESTS_ACTIVATION)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REQUESTS_ACTIVATION)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let parameters = ["state" : enable]
        let headers = ["Authorization" : userDefault.getToken()!]

        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let enableRequestsResponse = EnableRequestsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(enableRequestsResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                        
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(enableRequestsResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(enableRequestsResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getDelegateCurrentOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_CURRENT_ORDERS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_CURRENT_ORDERS)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        let parameters = ["page" : page , "limit" : limit]
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .get, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let myOrdersResponse = MyOrdersResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(myOrdersResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(myOrdersResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(myOrdersResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
        
        
    }
    
    func getDelegatePastOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_PAST_ORDERS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_PAST_ORDERS)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        let parameters = ["page" : page , "limit" : limit]
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .get, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let myOrdersResponse = MyOrdersResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(myOrdersResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(myOrdersResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(myOrdersResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getDelegateReviews(id: Int, page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyReviewsResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.USERS)/\(id)/\(APIURLs.DELEGATE_DETAILS)/\(APIURLs.REVIEWS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.USERS)/\(id)/\(APIURLs.DELEGATE_DETAILS)/\(APIURLs.REVIEWS)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        let parameters = ["page" : page , "limit" : limit]
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .get, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let myReviewsResponse = MyReviewsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(myReviewsResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(myReviewsResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(myReviewsResponse, NetworkUserRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkUserRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkUserRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkUserRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkUserRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkUserRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkUserRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func ignoreOrder(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDERS)/\(id)/\(APIURLs.IGNORE_ORDER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDERS)/\(id)/\(APIURLs.IGNORE_ORDER)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .post, headers : headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkDelegateRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkDelegateRepository.ErrorType.network)
                    }
                }
        }
    }
}
