//
//  DelegateRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit


protocol DelegateRepository {
    
    func uploadDelegateImage(imageFile : UIImage?, type : String, completionHandler: @escaping (_ resultData : UploadDelegateImageResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())

    func deleteDelegateImage(id : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())

    func requestDelegate(carDetails : String,images: String, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())
    
    func getCarDetails(completionHandler: @escaping (_ resultData : CarDetailsResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())
    
    func enableDelegateRequests(enable : Bool , completionHandler: @escaping (_ resultData : EnableRequestsResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())
    
    func getDelegateCurrentOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())
    
    func getDelegatePastOrders(page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyOrdersResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())
    
    func getDelegateReviews(id: Int, page : Int , limit : Int , completionHandler: @escaping (_ resultData : MyReviewsResponse?, _ error : NetworkUserRepository.ErrorType) -> ())
    
    func ignoreOrder(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkDelegateRepository.ErrorType) -> ())


}
