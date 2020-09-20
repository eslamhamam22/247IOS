//
//  NoNetworkPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 4/4/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class NoNetworkPresenter : Presenter{
    
    var view : NoNetworkView?
    var infoRepository: InfoRepository!
    var delegateRepository: DelegateRepository!
    var userRepository: UserRepository!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (infoRepository: InfoRepository, delegateRepository: DelegateRepository, userRepository: UserRepository!) {
        self.infoRepository = infoRepository
        self.delegateRepository = delegateRepository
        self.userRepository = userRepository
    }
    
    func setView(view: NoNetworkView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getAboutUs(){
        self.view?.showloading()
        infoRepository.getPages(slug: "about-us") { (result, error) in
            self.view?.hideLoading()
            if error == NetworkInfoRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setAboutUsData(data: (result?.data)!)
                }
            }else if error == NetworkInfoRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.auth{
                self.userDefault.removeSession()
            }else if error == NetworkInfoRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func getContactUs(){
        self.view?.showloading()
        infoRepository.getContactUs { (result, error) in
            self.view?.hideLoading()
            if error == NetworkInfoRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setContactUsData(data: (result?.data)!)
                }
            }else if error == NetworkInfoRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.auth{
                self.userDefault.removeSession()
            }else if error == NetworkInfoRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func getCarDetails(){
        self.view?.showloading()
        delegateRepository.getCarDetails { (result, error) in
            self.view?.hideLoading()
            if error == NetworkDelegateRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setCarDetailsData(data: (result?.data)!)
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
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol NoNetworkView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func setAboutUsData(data: PagesData)
    func setContactUsData(data: ContactUsData)
    func setCarDetailsData(data: CarDetailsData)
    func showSusspendedMsg(msg : String)
}



