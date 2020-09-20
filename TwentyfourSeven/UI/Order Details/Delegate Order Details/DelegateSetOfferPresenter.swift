//
//  DelegateSetOfferPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/17/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class DelegateSetOfferPresenter : Presenter{
    
    var view : DelegateSetOfferView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: DelegateSetOfferView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func setOffer(id: Int, cost: Double, distanceToPickup: Double, distanceToDestination: Double, currentLat: Double, currentLng: Double){
        self.view?.showloading()
        orderRepository.setOffer(id: id, cost: cost, distanceToPickup: distanceToPickup, distanceToDestination: distanceToDestination, currentLat: currentLat, currentLng: currentLng) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                self.view?.showSuccess()
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
    
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol DelegateSetOfferView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func showSuccess()
}
