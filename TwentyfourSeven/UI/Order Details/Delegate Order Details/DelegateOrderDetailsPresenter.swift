//
//  UserOrderDetailsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/17/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class DelegateOrderDetailsPresenter : Presenter{
    
    var view : DelegateOrderDetailsView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    var delegateRepository: DelegateRepository!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    let WEB_API_KEY = AppKeys.WEB_API_KEY
    
    init (repository: OrderRepository, userRepository: UserRepository, delegateRepository: DelegateRepository) {
        orderRepository = repository
        self.userRepository = userRepository
        self.delegateRepository = delegateRepository
    }
    
    func setView(view: DelegateOrderDetailsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getDelegateOrderDetails(id: Int, isFromReload: Bool){
        if isFromReload{
            self.view?.showloading(isFromCancel: true)
        }else{
            self.view?.showloading(isFromCancel: false)
        }
        orderRepository.getDelegateOrderDetails(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.order != nil{
                        self.view?.setData(order: (result?.data?.order)!)
                    }
                    if result?.data?.free_commission != nil{
                        self.view?.setFreeCommission(isFreeCommission: (result?.data?.free_commission)!)
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
                        self.view?.showNotAvailabeOrder(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkOrderRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showNotAvailabeOrder(msg: (result?.error?.defaultError)!)
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
    
    func calculateDistance(isDelegatePath: Bool, orderStatus: String){
    
        DispatchQueue.main.async {
            if isDelegatePath{
                if orderStatus == "delivery_in_progress"{
                    self.view?.getFromDelegateToDestinationDistance()
                }else{
                    self.view?.getFromDelegateToPickupDistance()
                }
                
            }else{
                self.view?.getFromPickupToDistinationDistance()
            }
        }
        
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, isDelegatePath: Bool, orderStatus: String){
       // var isDistanceCalculated = false
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(WEB_API_KEY)")!
        print(url)
    
        calculateDistance(isDelegatePath: isDelegatePath, orderStatus: orderStatus)
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in

            if error != nil {
                print(error!.localizedDescription)
                
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
                                        DispatchQueue.main.async {
                                            self.view?.showPath(polyStr: polyString!, isDelegatePath: isDelegatePath)
                                        }
                                    }
                                    //get distance
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
    
    func cancelOffer(id : Int){
        self.view?.showloading(isFromCancel: true)
        orderRepository.cancelOffer(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
               self.view?.cancelOfferSuccessfully()
            }else if error == NetworkOrderRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkOrderRepository.ErrorType.auth{
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
    
    
    func ignoreOrder(id : Int){
        self.view?.showloading(isFromCancel: true)
        delegateRepository.ignoreOrder(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                self.view?.ignoreOrderSuccessfully()
            }else if error == NetworkDelegateRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
            }else if error == NetworkDelegateRepository.ErrorType.suspended{
                //                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                        self.view?.ignoreOrderSuccessfully()
                    }
                }
            }else if error == NetworkDelegateRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkDelegateRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol DelegateOrderDetailsView : class {
    func showloading(isFromCancel: Bool)
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showNotAvailabeOrder(msg : String)
    func showSusspendedMsg(msg : String)
    func setData(order: Order)
    func setFreeCommission(isFreeCommission: Bool)

    //route functions
    func setDistance(isDelegatePath: Bool, distanceValue: Double)
    func showPath(polyStr :String, isDelegatePath: Bool)
    func getFromPickupToDistinationDistance()
    func getFromDelegateToPickupDistance()
    func getFromDelegateToDestinationDistance()

    //cancel offer
    func cancelOfferSuccessfully()
    
    //ignore order
    func ignoreOrderSuccessfully()

}
