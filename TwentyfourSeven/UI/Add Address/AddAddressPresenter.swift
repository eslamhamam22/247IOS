//
//  AddAddressPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/3/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class AddAddressPresenter : Presenter{
    
    var view : AddAddressView?
    var addressesRepository: AddressesRepository!
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: AddressesRepository, userRepository: UserRepository) {
        addressesRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: AddAddressView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func addAddress(title: String, address: String, latitude: Double, longitude: Double){
        self.view?.showloading()
        addressesRepository.addAddress(title: title, address: address, lat: latitude, lng: longitude) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkAddressesRepository.ErrorType.none{
                self.view?.successAdd()
            }else if error == NetworkAddressesRepository.ErrorType.invalidValue{
                self.view?.showValidationError()
            }else if error == NetworkAddressesRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkAddressesRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkAddressesRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkAddressesRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkAddressesRepository.ErrorType.generalError{
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

protocol AddAddressView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showNoData()
    func showValidationError()
    func showSusspendedMsg(msg : String)
    func successAdd()
}
