//
//  NetworkOrderRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/24/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class NetworkOrderRepository : OrderRepository {
    
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
        case blockedArea
    }
    
    func requestOrder(desc: String, fromType: Int, fromLat: Double, fromLng: Double, toLat: Double, toLng: Double, fromAddress: String, toAddress: String, storeName: String, images: String, voicenoteId: Int, is_reorder:Bool, deliveryDuration: Int, couponCode: String, completionHandler: @escaping (OrderDetailsResponse?, NetworkOrderRepository.ErrorType) -> ()) {
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REQUEST_ORDER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REQUEST_ORDER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        var parameters = ["fromType" : fromType,
                          "fromLat" : String(fromLat),
                          "fromLng" : String(fromLng),
                          "fromAddress" : fromAddress,
                          "toLat" : String(toLat),
                          "toLng" : String(toLng),
                          "toAddress" : toAddress,
                          "deliveryDuration" : deliveryDuration,
                          "storeName" : storeName] as [String : Any]

        if desc != ""{
            parameters.updateValue(desc, forKey: "description")
        }
        
        if voicenoteId != 0{
            parameters.updateValue(voicenoteId, forKey: "voicenote")
        }
        
        if images != ""{
            parameters.updateValue(images, forKey: "images")
        }
        
        if is_reorder{
            parameters.updateValue(is_reorder, forKey: "is_reorder")
        }

        if couponCode != ""{
            parameters.updateValue(couponCode, forKey: "couponCode")
        }
        
        print(parameters.description)
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let errorStr = self.handleError(response: response.result.value!)
                    if errorStr != ""{
                        orderDetailsResponse.error?.defaultError = errorStr
                    }
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
//                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.blockedArea)
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func uploadRecord(recordData: Data, completionHandler: @escaping (_ resultData : UploadRecordResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ORDER_RECORD)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ORDER_RECORD)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let URL = try! URLRequest(url: url, method: .post, headers : headers)
        Alamofire.upload(multipartFormData: {
            
            (multipartFormData) in
            
            multipartFormData.append(recordData, withName: "voicenoteFile", fileName: "sound.wav", mimeType: "wav")
            //                for (key, value) in parameters {
            //                    multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            //                }
            
        }, with: URL, encodingCompletion: {
            (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(_):
                        print(response.description)
                        let uploadRecordResponse = UploadRecordResponse(json: response.result.value! as! JSON)!
                        let statusCode = response.response?.statusCode
                        if(statusCode == 200){
                            completionHandler(uploadRecordResponse, NetworkOrderRepository.ErrorType.none)
                        }else if statusCode == 422{
                            completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                        }else if statusCode == 401{
                            completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                        }else if statusCode == 403{
                            completionHandler(uploadRecordResponse, NetworkOrderRepository.ErrorType.suspended)
                        }else if statusCode == 409{
                            completionHandler(uploadRecordResponse, NetworkOrderRepository.ErrorType.controlError)
                        }else if (statusCode == 500 || statusCode == 503) {
                            completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                        }else if Utils.isConnectedToNetwork(){
                            completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                        }else{
                            completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                        }
                        
                    case .failure(_):
                        let statusCode = response.response?.statusCode
                        print(response.description)
                        if statusCode == 422{
                            completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                        }else if statusCode == 400 || statusCode == 401{
                            completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                        }else if (statusCode == 500 || statusCode == 503) {
                            completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                        }else if Utils.isConnectedToNetwork(){
                            completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                        }else{
                            completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                        }
                    }
                    
                }
            case .failure(_):
                print("failure")
                if Utils.isConnectedToNetwork(){
                    completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                }else{
                    completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                }
            }
        })
        
    }
    
    func deleteRecord(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ORDER_RECORD)/\(String(describing: id))"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ORDER_RECORD)/\(String(describing: id))"
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
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func uploadChatImage(orderId : Int , imageFile: UIImage?, completionHandler: @escaping (_ resultData : UploadDelegateImageResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
       
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REQUEST_ORDER)/\(orderId)/\(APIURLs.CHAT_IMAGES)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REQUEST_ORDER)/\(orderId)/\(APIURLs.CHAT_IMAGES)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        if(imageFile != nil) {
            let URL = try! URLRequest(url: url, method: .post, headers : headers)
            Alamofire.upload(multipartFormData: {
                
                (multipartFormData) in
                
                if let imageData = imageFile?.jpegData(compressionQuality: 0.6) {
                    multipartFormData.append(imageData, withName: "imageFile", fileName: "pp.jpg", mimeType: "image/jpg")
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
                                completionHandler(uploadDelegateImageResponse, NetworkOrderRepository.ErrorType.none)
                            }else if statusCode == 422{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                            }else if statusCode == 401{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                            }else if statusCode == 403{
                                completionHandler(uploadDelegateImageResponse, NetworkOrderRepository.ErrorType.suspended)
                            }else if statusCode == 409{
                                completionHandler(uploadDelegateImageResponse, NetworkOrderRepository.ErrorType.controlError)
                            }else if (statusCode == 500 || statusCode == 503) {
                                completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                            }else if Utils.isConnectedToNetwork(){
                                completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                            }else{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                            }
                            
                        case .failure(_):
                            let statusCode = response.response?.statusCode
                            print(response.description)
                            if statusCode == 422{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                            }else if statusCode == 400 || statusCode == 401{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                            }else if (statusCode == 500 || statusCode == 503) {
                                completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                            }else if Utils.isConnectedToNetwork(){
                                completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                            }else{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                            }
                        }
                        
                    }
                case .failure(_):
                    print("failure")
                    completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                }
            })
            
        } else {
            completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
        }
        
    }
    
    func uploadImage(imageFile: UIImage?, completionHandler: @escaping (_ resultData : UploadDelegateImageResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ORDER_IMAGE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ORDER_IMAGE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        if(imageFile != nil) {
            let URL = try! URLRequest(url: url, method: .post, headers : headers)
            Alamofire.upload(multipartFormData: {
                
                (multipartFormData) in
                
                if let imageData = imageFile?.jpegData(compressionQuality: 0.6) {
                    multipartFormData.append(imageData, withName: "imageFile", fileName: "pp.jpg", mimeType: "image/jpg")
                }
//                for (key, value) in parameters {
//                    multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
//                }
                
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
                                completionHandler(uploadDelegateImageResponse, NetworkOrderRepository.ErrorType.none)
                            }else if statusCode == 422{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                            }else if statusCode == 401{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                            }else if statusCode == 403{
                                completionHandler(uploadDelegateImageResponse, NetworkOrderRepository.ErrorType.suspended)
                            }else if statusCode == 409{
                                completionHandler(uploadDelegateImageResponse, NetworkOrderRepository.ErrorType.controlError)
                            }else if (statusCode == 500 || statusCode == 503) {
                                completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                            }else if Utils.isConnectedToNetwork(){
                                completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                            }else{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                            }
                            
                        case .failure(_):
                            let statusCode = response.response?.statusCode
                            print(response.description)
                            if statusCode == 422{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                            }else if statusCode == 400 || statusCode == 401{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                            }else if (statusCode == 500 || statusCode == 503) {
                                completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                            }else if Utils.isConnectedToNetwork(){
                                completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                            }else{
                                completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                            }
                        }
                        
                    }
                case .failure(_):
                    print("failure")
                    completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                }
            })
            
        } else {
            completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
        }
    }
    
    func deleteImage(id : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.ORDER_IMAGE)/\(String(describing: id))"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.ORDER_IMAGE)/\(String(describing: id))"
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
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getCustomerOrderDetails(id : Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(String(describing: id))"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(String(describing: id))"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        Alamofire.request(url, method: .get, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print("FAILURE: getCustomerOrderDetails")
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getDelegateOrderDetails(id : Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        Alamofire.request(url, method: .get, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func setOffer(id: Int, cost: Double, distanceToPickup: Double, distanceToDestination: Double, currentLat: Double, currentLng: Double, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.OFFERS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.OFFERS)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let parameters = ["cost" : cost,
                          "distToPickup" : distanceToPickup,
                          "distToDelivery" : distanceToDestination,
                          "delegateLat" : currentLat,
                          "delegateLng" : currentLng] as [String : Any]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func acceptOffer(id: Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(APIURLs.OFFERS)/\(String(describing: id))/\(APIURLs.ACCEPT_OFFER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(APIURLs.OFFERS)/\(String(describing: id))/\(APIURLs.ACCEPT_OFFER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        
        Alamofire.request(url, method: .post, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
        
    }
    
    func rejectOffer(id: Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(APIURLs.OFFERS)/\(String(describing: id))/\(APIURLs.REJECT_OFFER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(APIURLs.OFFERS)/\(String(describing: id))/\(APIURLs.REJECT_OFFER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        
        Alamofire.request(url, method: .post, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func cancelOffer(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(APIURLs.OFFERS)/\(String(describing: id))/\(APIURLs.CANCEL_OFFER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(APIURLs.OFFERS)/\(String(describing: id))/\(APIURLs.CANCEL_OFFER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        Alamofire.request(url, method: .post, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
        
    }
    
    func refreshDelegates(id: Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.REFRESH_DELEGATES)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.REFRESH_DELEGATES)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        Alamofire.request(url, method: .post, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func cancelOrder(id: Int, reason : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)/\(APIURLs.REQUEST_ORDER)/\(String(describing: id))/\(APIURLs.CANCEL_OFFER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)/\(APIURLs.REQUEST_ORDER)/\(String(describing: id))/\(APIURLs.CANCEL_OFFER)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let parameters = ["cancelReason" : reason] as [String : Any]

        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
        
    }
    
    func cancelDelegateOrder(id: Int, reason : Int , completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.CANCEL_OFFER)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.CANCEL_OFFER)"

        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let parameters = ["cancelReason" : reason] as [String : Any]
        
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
        
    }
    
    func startRide(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.START_RIDE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.START_RIDE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        Alamofire.request(url, method: .post, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func pickItem(id: Int,price: Double, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.PICK_ITEM)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.PICK_ITEM)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        var parameters = [String : Any]()
        
        if price != 0.0 {
            parameters = ["item_price" : price] as [String : Any]
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func completeRide(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.COMPLETE_RIDE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: id))/\(APIURLs.COMPLETE_RIDE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

        let parameters = ["delegate_app_version" : appVersionString] as [String : Any]

        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
        
    }
    
    func addRate(orderId: Int, rating: Int, comment: String, isUserRateDelegate: Bool, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        
        if isUserRateDelegate{ // user make rate to deleagte so call "Rate order delegate" api
            if appDelegate.isRTL {
                url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(String(describing: orderId))/\(APIURLs.RATE)"
            }else{
                url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CUSTOMER_ORDER_DETAILS)/\(String(describing: orderId))/\(APIURLs.RATE)"
            }
        }else{ // delegate make rate to user so call "Rate order customer" api
            if appDelegate.isRTL {
                url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: orderId))/\(APIURLs.RATE)"
            }else{
                url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DELEGATE_ORDER_DETAILS)/\(String(describing: orderId))/\(APIURLs.RATE)"
            }
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String:String]()
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        var parameters = ["rating" : rating] as [String : Any]
        
        if comment != "" {
            parameters.updateValue(comment, forKey: "comment")
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let orderDetailsResponse = OrderDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(orderDetailsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func submitComplaint(id: Int, title: String, desc: String, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REQUEST_ORDER)/\(String(describing: id))/\(APIURLs.COMPLAINTS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REQUEST_ORDER)/\(String(describing: id))/\(APIURLs.COMPLAINTS)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        
        let parameters = ["title" : title,
                          "description" : desc] as [String : Any]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getCancellationReasons(isDelegate: Bool, completionHandler: @escaping (_ resultData : CancellationReasonsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CACELLATION_REASONS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CACELLATION_REASONS)"
        }
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")

        var type = 1
        if isDelegate{
            type = 2
        }
        
        let parameters = ["type" : type] as [String : Any]
        
        Alamofire.request(url, method: .get, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let cancellationReasonsResponse = CancellationReasonsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(cancellationReasonsResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(cancellationReasonsResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(cancellationReasonsResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func validateCoupon(code: String, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.VALIDATE_COUPON)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.VALIDATE_COUPON)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        var token = ""
        if userDefault.getToken() != nil{
            token = userDefault.getToken()!
        }
        
        let headers = ["Authorization" : token]
        let parameters = ["code" : code]

        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkOrderRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkOrderRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkOrderRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkOrderRepository.ErrorType.network)
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
