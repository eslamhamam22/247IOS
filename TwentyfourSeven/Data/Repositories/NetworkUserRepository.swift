//
//  NetworkUserRepository.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Alamofire
import Gloss
import MBProgressHUD

class NetworkUserRepository: UserRepository {
  
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loginPresenter: LoginPresenter!
    let userDefault = UserDefault()
    var loadingView: MBProgressHUD!

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
    
    func loginWithGoogle(_ loginPresenter: LoginPresenter) {
        self.loginPresenter = loginPresenter
        AppDelegate.getInstance().loginWithGoogle(self)
    }
    
    func getGoogleToken(_ token: String) {
        print("token: \(token)")
        loginPresenter.sendGoogleToken(token: token)
    }
    
    func loginWithFacebook(_ viewController: UIViewController, completionHandler: @escaping (_ resultData : String, _ error : NetworkUserRepository.ErrorType) -> ()) {
        if (FBSDKAccessToken.current() != nil){
            completionHandler(FBSDKAccessToken.current().tokenString, NetworkUserRepository.ErrorType.none)
            
        } else {
            let login = FBSDKLoginManager()
            login.loginBehavior = FBSDKLoginBehavior.systemAccount
            login.logIn(withReadPermissions: ["public_profile", "email"], from: viewController, handler: {(result, error) in
                if error != nil {
                    completionHandler("", NetworkUserRepository.ErrorType.auth)
                    
                } else if (result?.isCancelled)! {
                    completionHandler("", NetworkUserRepository.ErrorType.auth)
                    
                } else {
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, name, id, gender"]).start(completionHandler: {(connection, result, error) -> Void in
                        if error != nil {
                            completionHandler("", NetworkUserRepository.ErrorType.auth)
                            
                        } else {
                            guard let userInfo = result as? [String: Any] else { return } //handle the error
                            
                            //The url is nested 3 layers deep into the result so it's pretty messy
                            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                                //Download image from imageURL
                                print(imageURL)
//                                self.userDefault.setProfileImage(imageURL)
                                
                            }
                            completionHandler(FBSDKAccessToken.current().tokenString, NetworkUserRepository.ErrorType.none)
                        }
                    })
                }
            })
        }
    }
    
    func socialLogin(isFacebook: Bool, token: String, completionHandler: @escaping (SocialLoginResponse?, NetworkUserRepository.ErrorType) -> ()) {
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.SOCIAL_LOGIN)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.SOCIAL_LOGIN)"
        }
       
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var  parameters = [String : Any]()
        
        if isFacebook {
            parameters = ["facebookToken" : token]
        }else{
            parameters = ["googleToken" : token]
        }
       
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let socialLoginResponse = SocialLoginResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(socialLoginResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 400 {
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401 {
                        completionHandler(socialLoginResponse, NetworkUserRepository.ErrorType.suspended)
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
                    if statusCode == 400 {
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
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
    
    func requestCode(mobileNumber: String, completionHandler: @escaping (_ resultData : RequestCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REQUEST_CODE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REQUEST_CODE)"
        }
        
//        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let parameters = ["mobile" : mobileNumber]
        
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let requestCodeResponse = RequestCodeResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(requestCodeResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 400{
                        completionHandler(requestCodeResponse, NetworkUserRepository.ErrorType.TimeError)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 422{
                        completionHandler(requestCodeResponse, NetworkUserRepository.ErrorType.invalidValue)
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
                    if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkUserRepository.ErrorType.serverError)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.suspended)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkUserRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkUserRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func verifyCode(mobileNumber: String, code: String, socialToken: String, isFacebook: Bool, completionHandler: @escaping (_ resultData : VerifyCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.VERIFY_CODE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.VERIFY_CODE)"
        }
        
        //url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var parameters = ["mobile" : mobileNumber,
                          "code" : code]
        
        if socialToken != "" {
            if isFacebook{
                parameters.updateValue(socialToken, forKey: "facebookToken")
            }else{
                parameters.updateValue(socialToken, forKey: "googleToken")
            }
        }
        
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let jsonString = response.result.value! as! JSON
                    let verifyCodeResponse = VerifyCodeResponse(json: jsonString)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(verifyCodeResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 401{
                        completionHandler(verifyCodeResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 400 || statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
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
                    if statusCode == 400 || statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
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
    
    func updateRequestCode(mobileNumber: String, completionHandler: @escaping (_ resultData : RequestCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.UPDATE_REQUEST_CODE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.UPDATE_REQUEST_CODE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        var headers = [String : String]()
        
        // if we have token so come from change phone number
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let parameters = ["mobile" : mobileNumber]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let requestCodeResponse = RequestCodeResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(requestCodeResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 400{
                        completionHandler(requestCodeResponse, NetworkUserRepository.ErrorType.TimeError)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 422{
                        completionHandler(requestCodeResponse, NetworkUserRepository.ErrorType.invalidValue)
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
                    if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkUserRepository.ErrorType.serverError)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.suspended)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkUserRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkUserRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func updateVerifyCode(mobileNumber: String, code: String, completionHandler: @escaping (_ resultData : VerifyCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.UPDATE_VERIFY_CODE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.UPDATE_VERIFY_CODE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        var headers = [String : String]()
        
        // if we have token so come from change phone number
        if userDefault.getToken() != nil{
            headers = ["Authorization" : userDefault.getToken()!]
        }
        
        let parameters = ["mobile" : mobileNumber,
                          "code" : code]
        
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let verifyCodeResponse = VerifyCodeResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(verifyCodeResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(verifyCodeResponse, NetworkUserRepository.ErrorType.suspended)
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
                    if statusCode == 400 || statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
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
    
    func updateProfile(mobileNumber: String, name: String, birthdate: String, city: String, gender: String, language: String, imageFile: UIImage?, completionHandler: @escaping (UpdateProfileResponse?, NetworkUserRepository.ErrorType) -> ()) {
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
//        var parameters = ["mobile" : mobileNumber,
//                          "name" : name]
        
        var parameters = ["name" : name]
        
        if birthdate != ""{
            parameters.updateValue(birthdate, forKey: "birthdate")
        }
       
        if city != ""{
            parameters.updateValue(city, forKey: "city")
        }
        
        if gender != ""{
            parameters.updateValue(gender, forKey: "gender")
        }
        
        
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
                            let updateProfileResponse = UpdateProfileResponse(json: response.result.value! as! JSON)!
                            let statusCode = response.response?.statusCode
                            if(statusCode == 200){
                                completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.none)
                            }else if statusCode == 422{
                                completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                            }else if statusCode == 401{
                                completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                            }else if statusCode == 403{
                                completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.suspended)
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
                case .failure(_):
                    print("failure")
                    completionHandler(nil, NetworkUserRepository.ErrorType.network)
                }
            })
            
        } else {
            Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(_):
                        print(response.description)
                        let updateProfileResponse = UpdateProfileResponse(json: response.result.value! as! JSON)!
                        let statusCode = response.response?.statusCode
                        if(statusCode == 200){
                            completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.none)
                        }else if statusCode == 422{
                            completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                        }else if statusCode == 401{
                            completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                        }else if statusCode == 403{
                            completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.suspended)
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
    }
    
    func changeLanguage(language: String, completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.LANGUAGE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.LANGUAGE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let headers = ["Authorization" : userDefault.getToken()!]
        let parameters = ["lang" : language]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let updateProfileResponse = UpdateProfileResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.suspended)
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
                    }else if statusCode == 401{
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
    
    func refreshToken(refreshToken: String, completionHandler: @escaping (_ resultData : VerifyCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REFRESH)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REFRESH)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        let parameters = ["refresh_token" : refreshToken]
        
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response.description)
                    let verifyCodeResponse = VerifyCodeResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(verifyCodeResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        //suspended user log out
                        self.userDefault.removeSession()
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(verifyCodeResponse, NetworkUserRepository.ErrorType.suspended)
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
                    }else if statusCode == 401{
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
    
    func registerForPushNotification( playedId : String, token : String?, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.NOTIFICATION_REGISTERATION)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.NOTIFICATION_REGISTERATION)"
        }
        
        url = url + "?token=" + token!
        print("url \(url)")
        var headers = [String : String]()
        /*if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }else if token != nil{
            headers.updateValue( "Bearer "+token!, forKey: "Authorization")
        }*/
        
        let parameters = ["playerId" : playedId]

        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.controlError)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.suspended)
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
    
    func unregisterForPushNotification(completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
    
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.NOTIFICATION_REGISTERATION)/\(userDefault.getPlayerID()!)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.NOTIFICATION_REGISTERATION)/\(userDefault.getPlayerID()!)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .delete, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.controlError)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.suspended)
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
    
    func unregisterPlayerId(completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.DEVICES)/\(userDefault.getPlayerID()!)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.DEVICES)/\(userDefault.getPlayerID()!)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        
//        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .delete, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.controlError)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.suspended)
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
    
    func getUserNotification(page : Int , limit : Int , completionHandler: @escaping (_ resultData : NotificationListResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.NOTIFICATIONS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.NOTIFICATIONS)"
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
                    let notificationListResponse = NotificationListResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(notificationListResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(notificationListResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(notificationListResponse, NetworkUserRepository.ErrorType.controlError)
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
    
    func markNotificationAsSeen(completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.NOTIFICATIONS_READ)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.NOTIFICATIONS_READ)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .post, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let basicResponse = BasicResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(basicResponse, NetworkUserRepository.ErrorType.controlError)
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

    func changeNotificationStatus(status : Bool , completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.NOTIFICATIONS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.NOTIFICATIONS)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        let parameters = ["state" : status]

        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        Alamofire.request(url, method: .post, parameters: parameters, headers : headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let updateProfileResponse = UpdateProfileResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.controlError)
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
    
    func getProfile(completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)"
        }
        
        var headers = [String : String]()
        if userDefault.getToken() != nil{
            headers.updateValue(userDefault.getToken()!, forKey: "Authorization")
        }
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let updateProfileResponse = UpdateProfileResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(updateProfileResponse, NetworkUserRepository.ErrorType.controlError)
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
    
    func generalRefreshToken() -> (){
        self.showloading()
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.REFRESH)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.REFRESH)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        var refreshToken = ""
        if userDefault.getRefreshToken() != nil{
            refreshToken = userDefault.getRefreshToken()!
        }
        let parameters = ["refresh_token" : refreshToken]
        
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                self.hideLoading()
                switch response.result {
                case .success(_):
                    print(response.description)
                    let refreshResponse = VerifyCodeResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    
                    if(statusCode == 200){
                        if refreshResponse.data != nil{
                            if refreshResponse.data?.token != nil{
                                let token  = "Bearer " + (refreshResponse.data?.token!)!
                                self.userDefault.setToken(token)
                            }
                            if refreshResponse.data?.refresh_token != nil{
                                self.userDefault.setRefreshToken(refreshResponse.data?.refresh_token)
                            }
                            self.appDelegate.isFromNotifications = false
                            self.appDelegate.loadAndSetRootWindow()
                        }
                    }else if statusCode == 422{
                        self.userDefault.removeSession()
                    }else if statusCode == 401{
                        self.userDefault.removeSession()
                    }else if statusCode == 403{
                        self.userDefault.removeSession()
                    }else if (statusCode == 500 || statusCode == 503) {
                        self.userDefault.removeSession()
                    }else if Utils.isConnectedToNetwork(){
                        self.userDefault.removeSession()
                    }else{
                        print("network error")
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        self.userDefault.removeSession()
                    }else if statusCode == 401{
                        self.userDefault.removeSession()
                    }else if (statusCode == 500 || statusCode == 503) {
                        self.userDefault.removeSession()
                    }else if Utils.isConnectedToNetwork(){
                        self.userDefault.removeSession()
                    }else{
                        print("network error")
                    }
                }
        }
    }
    
    func getUserCurrentOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.USER_CURRENT_ORDERS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.USER_CURRENT_ORDERS)"
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
                        completionHandler(myOrdersResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(myOrdersResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(myOrdersResponse, NetworkUserRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkUserRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkUserRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkUserRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print("FAILURE: getUserCurrentOrders")
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
    
    func getUserPastOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.USER_PAST_ORDERS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.USER_PAST_ORDERS)"
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
                        completionHandler(myOrdersResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(myOrdersResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(myOrdersResponse, NetworkUserRepository.ErrorType.controlError)
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
    
    func getUserReviews(id: Int, page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyReviewsResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.USERS)/\(id)/\(APIURLs.REVIEWS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.USERS)/\(id)/\(APIURLs.REVIEWS)"
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
    
    func getComplaints(page : Int , limit : Int , completionHandler: @escaping (_ resultData : ComplaintsResponse?, _ error : NetworkUserRepository.ErrorType) -> ()){
        
        var url = ""
        if self.appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PROFILE)/\(APIURLs.COMPLAINTS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PROFILE)/\(APIURLs.COMPLAINTS)"
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
                    let complaintsResponse = ComplaintsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(complaintsResponse, NetworkUserRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkUserRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkUserRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(complaintsResponse, NetworkUserRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(complaintsResponse, NetworkUserRepository.ErrorType.controlError)
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
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    func showloading() {
        loadingView = MBProgressHUD.showAdded(to: self.topMostController().view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
    }
}
