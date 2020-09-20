//
//  ViewFullImagePresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/10/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class ViewFullImagePresenter : Presenter{
    
    var view : ViewFullImageView?
    var orderRepository: OrderRepository!
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var isSubmitAndUpload = false
    
    init (repository: OrderRepository, userRepository: UserRepository) {
        orderRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: ViewFullImageView) {
        weak var weakView = view
        self.view = weakView
    }
    
 
    func uploadImage(imageFile: UIImage? , orderId : Int){
        self.view?.showloading()
        orderRepository.uploadChatImage(orderId: orderId, imageFile: imageFile) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkOrderRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setImage(image: (result?.data)!)
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
    
    
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol ViewFullImageView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func setImage(image: DelegateImageData)
    func showSusspendedMsg(msg : String)

}

