//
//  OrderRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/24/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit


protocol OrderRepository {
    
    func requestOrder(desc: String, fromType: Int, fromLat: Double, fromLng: Double, toLat: Double, toLng: Double, fromAddress: String, toAddress: String, storeName: String, images: String,voicenoteId: Int, is_reorder:Bool, deliveryDuration: Int, couponCode: String, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func uploadRecord(recordData: Data, completionHandler: @escaping (_ resultData : UploadRecordResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func deleteRecord(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func uploadImage(imageFile: UIImage?, completionHandler: @escaping (_ resultData : UploadDelegateImageResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func deleteImage(id : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func getCustomerOrderDetails(id : Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func getDelegateOrderDetails(id : Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func setOffer(id: Int, cost: Double, distanceToPickup: Double, distanceToDestination: Double, currentLat: Double, currentLng: Double, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func acceptOffer(id: Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func rejectOffer(id: Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func cancelOffer(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func refreshDelegates(id: Int, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
     func cancelOrder(id: Int, reason : Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func cancelDelegateOrder(id: Int, reason : Int , completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func startRide(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func pickItem(id: Int,price: Double, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func completeRide(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func addRate(orderId: Int, rating: Int, comment: String, isUserRateDelegate: Bool, completionHandler: @escaping (_ resultData : OrderDetailsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func uploadChatImage(orderId : Int , imageFile: UIImage?, completionHandler: @escaping (_ resultData : UploadDelegateImageResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())
    
    func submitComplaint(id: Int, title: String, desc: String, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func getCancellationReasons(isDelegate: Bool, completionHandler: @escaping (_ resultData : CancellationReasonsResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

    func validateCoupon(code: String, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkOrderRepository.ErrorType) -> ())

}
