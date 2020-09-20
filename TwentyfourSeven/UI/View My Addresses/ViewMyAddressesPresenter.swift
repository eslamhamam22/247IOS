//
//  ViewMyAddressesPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class ViewMyAddressesPresenter : Presenter{
    
    var view : ViewMyAddressesView?
    var addressesRepository: AddressesRepository!
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: AddressesRepository, userRepository: UserRepository) {
        addressesRepository = repository
        self.userRepository = userRepository
    }
    
    func setView(view: ViewMyAddressesView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getAddesses(){
        self.view?.showloading()
        addressesRepository.getAddresses { (result, error) in
            self.view?.hideLoading()
            if error == NetworkAddressesRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.count == 0{
                        self.view?.showNoData()
                    }else{
                        self.view?.setData(data: (result?.data)!)
                    }
                }
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
    
    func deleteAddess(id : Int){
        self.view?.showloading()
        addressesRepository.deleteAddress(id: id) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkAddressesRepository.ErrorType.none{
                self.view?.successDelete()
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

protocol ViewMyAddressesView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func setData(data: [Address])
    func showNoData()
    func showValidationError()
    func showSusspendedMsg(msg : String)
    func successDelete()
}
