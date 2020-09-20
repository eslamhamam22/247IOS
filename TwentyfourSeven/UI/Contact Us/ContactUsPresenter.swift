//
//  ContactUsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class ContactUsPresenter : Presenter{
    
    var view : ContactUsView?
    var infoRepository: InfoRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: InfoRepository) {
        infoRepository = repository
    }
    
    func setView(view: ContactUsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getContactUs(){
        self.view?.showloading()
        infoRepository.getContactUs { (result, error) in
            self.view?.hideLoading()
            if error == NetworkInfoRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setData(data: (result?.data)!)
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
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol ContactUsView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func setData(data: ContactUsData)
    
}
