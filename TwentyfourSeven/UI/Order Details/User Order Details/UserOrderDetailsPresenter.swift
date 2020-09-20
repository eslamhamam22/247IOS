//
//  OrderDetailsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/12/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class UserOrderDetailsPresenter : Presenter{
    
    var view : UserOrderDetailsView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    let WEB_API_KEY = AppKeys.WEB_API_KEY

    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: UserOrderDetailsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getCustomerOrderDetails(id: Int){
        self.view?.showloading(isFromAccept: false)
        orderRepository.getCustomerOrderDetails(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.setData(order: (result?.data?.order)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func acceptOffer(id: Int){
        self.view?.showloading(isFromAccept: true)
        orderRepository.acceptOffer(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.showSuccess(order: (result?.data?.order)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkToast()
            }
        }

    }
    
    func rejectOffer(id: Int){
        self.view?.showloading(isFromAccept: true)
        orderRepository.rejectOffer(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.rejectOfferSuccessfully(order: (result?.data?.order)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
                //                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkToast()
            }
        }
    }
    
    func refreshDelegates(id: Int){
        self.view?.showloading(isFromAccept: true)
        orderRepository.refreshDelegates(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.setData(order: (result?.data?.order)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func cancelOrder(id :Int, reason: Int){
        self.view?.showloading(isFromAccept: true)
        orderRepository.cancelOrder(id : id, reason: reason){ (result, error) in
                self.view?.hideLoading()
                if error == NetworkOrderRepository.ErrorType.none{
                    self.view?.cancelOrderSuccessfully()
                }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                    self.view?.showGeneralError()
                }else if error == NetworkOrderRepository.ErrorType.auth{
                    self.userRepository.generalRefreshToken()
                }else if error == NetworkOrderRepository.ErrorType.suspended{
//                    self.userDefault.removeSession()
                    if result?.error != nil{
                        if result?.error?.defaultError != nil{
                            self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                        }
                    }
                }else if error == NetworkOrderRepository.ErrorType.controlError{
                    if result?.error != nil{
                        if result?.error?.defaultError != nil{
                            self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                        }
                    }
                }else if error == NetworkOrderRepository.ErrorType.serverError{
                    self.view?.showGeneralError()
                }else if error == NetworkOrderRepository.ErrorType.generalError{
                    self.view?.showGeneralError()
                }else{
                    self.view?.showNetworkToast()
                }
            }
            
        
    }
    
    
    func reOrder(desc: String,fromType: Int, fromLat: Double, fromLng: Double, toLat: Double, toLng: Double, fromAddress: String, toAddress: String, storeName: String, images: String, voicenoteId: Int, deliveryDuration: Int){
        
        self.view?.showloading(isFromAccept: true)
        orderRepository.requestOrder(desc: desc, fromType: fromType, fromLat: fromLat, fromLng: fromLng, toLat: toLat, toLng: toLng, fromAddress: fromAddress, toAddress: toAddress, storeName: storeName, images: images, voicenoteId: voicenoteId, is_reorder: true, deliveryDuration: deliveryDuration, couponCode: "") { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.setData(order: (result?.data?.order)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
                //                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkOrderRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.blockedArea{
                self.view?.showBlockedAreaError()
            }else{
                self.view?.showNetworkToast()
            }
        }
    }
    
    
    func calculateDistance(isDelegatePath: Bool, orderStatus: String){
        DispatchQueue.main.async {
            if isDelegatePath{
                if orderStatus == "delivery_in_progress"{
                    self.view?.getFromDelegateToDestinationDistance()
                }else{
                    self.view?.getFromDelegateToPickupDistance()
                }
                
               // self.view?.getFromDelegateToPickupDistance()
            }else{
                self.view?.getFromPickupToDistinationDistance()
            }
        }
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, isDelegatePath: Bool, orderStatus: String){
        
        calculateDistance(isDelegatePath: isDelegatePath , orderStatus: orderStatus)
        
       // var isDistanceCalculated = false
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(WEB_API_KEY)")!
        print(url)

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in

            if error != nil {
                print(error!.localizedDescription)
//                DispatchQueue.main.async {
//                    if isDelegatePath{
//                        self.view?.getFromDelegateToPickupDistance()
//                    }else{
//                        self.view?.getFromPickupToDistinationDistance()
//                    }
//                }
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{

                        let preRoutes = json["routes"] as? NSArray
                        if preRoutes != nil{
                            if (preRoutes?.count)! > 0{
                                let routes = preRoutes![0] as? NSDictionary
                                if routes != nil{
                                    let routeOverviewPolyline:NSDictionary = routes!.value(forKey: "overview_polyline") as! NSDictionary
                                    let polyString = routeOverviewPolyline.object(forKey: "points") as? String
                                    if polyString != nil{
                                        //Call this method to draw path on map
//                                        DispatchQueue.main.async { //modify
//                                            self.view?.showPath(polyStr: polyString!, isDelegatePath: isDelegatePath)
//                                        }
                                    }
                                    //get distance
                                    //as it is not required to calculate distance via directions anymore
//                                    let legs = routes!.value(forKey: "legs") as? NSArray
//                                    if legs != nil{
//                                        if (legs?.count)! > 0{
//                                            let leg = legs![0] as? NSDictionary
//                                            let distance:NSDictionary = leg!.value(forKey: "distance") as! NSDictionary
//                                            let distanceValue = distance.object(forKey: "value") as? Double
//                                            if distanceValue != nil{
//                                                isDistanceCalculated = true
//                                                DispatchQueue.main.async {
//                                                    self.view?.setDistance(isDelegatePath: isDelegatePath, distanceValue: distanceValue!)
//                                                }
//                                            }
//                                        }
//                                    }
                                }
                            }
                        }
                    }
//                    if !isDistanceCalculated{
//                        DispatchQueue.main.async {
//                            if isDelegatePath{
//                                self.view?.getFromDelegateToPickupDistance()
//                            }else{
//                                self.view?.getFromPickupToDistinationDistance()
//                            }
//                        }
//                    }
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol UserOrderDetailsView : class {
    func showloading(isFromAccept: Bool)
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setData(order: Order)
    func showSuccess(order: Order)
    func cancelOrderSuccessfully()
    func rejectOfferSuccessfully(order: Order)
    func showNetworkToast()
    func showBlockedAreaError()
    
    //route functions
    func setDistance(isDelegatePath: Bool, distanceValue: Double)
    func showPath(polyStr :String, isDelegatePath: Bool)
    func getFromPickupToDistinationDistance()
    func getFromDelegateToPickupDistance()
    func getFromDelegateToDestinationDistance()
}

