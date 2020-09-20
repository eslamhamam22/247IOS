//
//  MenuOptionsPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/5/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class MenuOptionsPresenter : Presenter{

    var view : MenuOptionsView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }

    func setView(view: MenuOptionsView) {
        weak var weakView = view
        self.view = weakView
    }

    func cancelDelegateOrder(id :Int , reason : Int){
        self.view?.showloading()
        orderRepository.cancelDelegateOrder(id: id, reason: reason) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                self.view?.cancelOrderSuccessfully()
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

    func cancelUserOrder(id :Int, reason: Int){
        self.view?.showloading()
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
                self.view?.showNetworkError()
            }
        }
        
        
    }
    func getCancellationReasons(isDelegate: Bool){
        self.view?.showloading()
        orderRepository.getCancellationReasons(isDelegate: isDelegate) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setCancellationReasons(reasons: (result?.data)!)
                }
            }else{
                // failure so dismiss the view and show the error
                self.view?.cancellationReasonsFailure()
                if error == NetworkOrderRepository.ErrorType.invalidValue{
                    self.view?.showGeneralError()
                }else if error == NetworkOrderRepository.ErrorType.auth{
                    self.userRepository.generalRefreshToken()
                }else if error == NetworkOrderRepository.ErrorType.suspended{
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
    }
    
    func didLoad() {

    }

    func didAppear() {

    }

}

protocol MenuOptionsView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func cancelOrderSuccessfully()
    func setCancellationReasons(reasons: [CancellationReason])
    func cancellationReasonsFailure()
}

