//
//  ChatPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/3/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class ChatPresenter : Presenter{
    
    var view : ChatView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    let WEB_API_KEY = AppKeys.WEB_API_KEY
    
    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: ChatView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func startRide(orderID: Int){
        self.view?.showloading()
        orderRepository.startRide(id: orderID) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                //make order in_progress
                self.view?.showStatusChangedSuccessfully(newStatus: "in_progress")
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
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, isDelegatePath: Bool , orderStatus: String){
        
        calculateDistance(isDelegatePath: isDelegatePath , orderStatus: orderStatus)
        
        
        //        var isDistanceCalculated = false
        //        let config = URLSessionConfiguration.default
        //        let session = URLSession(configuration: config)
        
        //        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(WEB_API_KEY)")!
        //        print(url)
        
        //        let task = session.dataTask(with: url, completionHandler: {
        //            (data, response, error) in
        //
        //            if error != nil {
        //                print(error!.localizedDescription)
        ////                DispatchQueue.main.async {
        ////                    if isDelegatePath{
        ////                        self.view?.getFromDelegateToPickupDistance()
        ////                    }else{
        ////                        self.view?.getFromPickupToDistinationDistance()
        ////                    }
        ////                }
        //            }else{
        //                do {
        //                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
        //
        //                        let preRoutes = json["routes"] as? NSArray
        //                        if preRoutes != nil{
        //                            if (preRoutes?.count)! > 0{
        //                                let routes = preRoutes![0] as? NSDictionary
        //                                if routes != nil{
        //                                    //get distance
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
        //                                }
        //                            }
        //                        }
        //                    }
        ////                    if !isDistanceCalculated{
        ////                        DispatchQueue.main.async {
        ////                            if isDelegatePath{
        ////                                self.view?.getFromDelegateToPickupDistance()
        ////                            }else{
        ////                                self.view?.getFromPickupToDistinationDistance()
        ////                            }
        ////                        }
        ////
        ////
        ////                    }
        //                }catch{
        //                    print("error in JSONSerialization")
        //                }
        //            }
        //        })
        //        task.resume()
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol ChatView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func showStatusChangedSuccessfully(newStatus: String)
    
    //route functions
    func setDistance(isDelegatePath: Bool, distanceValue: Double)
    func getFromPickupToDistinationDistance()
    func getFromDelegateToPickupDistance()
    func getFromDelegateToDestinationDistance()
}

