//
//  UserRepository.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit


protocol UserRepository {
    func loginWithGoogle(_ loginPresenter: LoginPresenter)
    
    func getGoogleToken(_ token:String)
    
    func loginWithFacebook(_ viewController: UIViewController, completionHandler: @escaping (_ resultData : String, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func socialLogin(isFacebook: Bool, token: String, completionHandler: @escaping (_ resultData : SocialLoginResponse?, _ error : NetworkUserRepository.ErrorType) -> ())

    func requestCode(mobileNumber: String, completionHandler: @escaping (_ resultData : RequestCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func verifyCode(mobileNumber: String, code: String, socialToken: String, isFacebook: Bool, completionHandler: @escaping (_ resultData : VerifyCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func updateRequestCode(mobileNumber: String, completionHandler: @escaping (_ resultData : RequestCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func updateVerifyCode(mobileNumber: String, code: String, completionHandler: @escaping (_ resultData : VerifyCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func updateProfile(mobileNumber: String, name: String, birthdate: String, city: String, gender: String, language: String, imageFile : UIImage?, completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func changeLanguage(language: String, completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func refreshToken(refreshToken: String, completionHandler: @escaping (_ resultData : VerifyCodeResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func registerForPushNotification(playedId : String, token : String?, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func unregisterForPushNotification(completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func unregisterPlayerId(completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func getUserNotification(page : Int , limit : Int , completionHandler: @escaping (_ resultData : NotificationListResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func markNotificationAsSeen(completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func changeNotificationStatus(status : Bool , completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func getProfile(completionHandler: @escaping (_ resultData : UpdateProfileResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func generalRefreshToken() -> ()
    
    func getUserCurrentOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
     func getUserPastOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
  
    func getUserReviews(id: Int, page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyReviewsResponse?, _ error : NetworkUserRepository.ErrorType) -> ())

    func getComplaints(page : Int , limit : Int , completionHandler: @escaping (_ resultData : ComplaintsResponse?, _ error : NetworkUserRepository.ErrorType) -> ())

}
