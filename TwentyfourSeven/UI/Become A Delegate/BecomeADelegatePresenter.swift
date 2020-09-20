//
//  BecomeADelegatePresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class BecomeADelegatePresenter : Presenter{
    
    var view : BecomeADelegateView?
    var delegateRepository: DelegateRepository!
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: DelegateRepository, userRepository: UserRepository) {
        delegateRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: BecomeADelegateView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func uploadImage(imageFile: UIImage?, type: String){
        self.view?.showImageLoading(type: type)
        delegateRepository.uploadDelegateImage(imageFile: imageFile, type: type) { (result, error) in
            self.view?.hideImageLoading(type: type)
            if error == NetworkDelegateRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setImage(data: (result?.data)!, type: type)
                }
            }else if error == NetworkDelegateRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkDelegateRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
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
    
    func deleteImage(id: Int, type: String){
        self.view?.showImageLoading(type: type)
        delegateRepository.deleteDelegateImage(id: id) { (result, error) in
            self.view?.hideImageLoading(type: type)
            if error == NetworkDelegateRepository.ErrorType.none{
                self.view?.successDelete(type: type)
            }else if error == NetworkDelegateRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkDelegateRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkDelegateRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
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

    func requestDelegate(carDetails : String,images: String){
        self.view?.showloading()
        delegateRepository.requestDelegate(carDetails: carDetails, images: images) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                self.view?.successDelegateRequest()
            }else if error == NetworkDelegateRepository.ErrorType.invalidValue{
                self.view?.ShowAlreadyHaveRequest()
            }else if error == NetworkDelegateRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkDelegateRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
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

protocol BecomeADelegateView : class {
    
    func showloading()
    func hideLoading()
    func showImageLoading(type: String)
    func hideImageLoading(type: String)
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setImage(data: DelegateImageData, type: String)
    func successDelete(type: String)
    func successDelegateRequest()
    func ShowAlreadyHaveRequest()
}



