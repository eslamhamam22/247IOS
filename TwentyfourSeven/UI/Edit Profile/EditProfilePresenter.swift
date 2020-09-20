//
//  EditProfilePresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/13/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class EditProfilePresenter : Presenter{
    
    var view : EditProfileView?
    var userRepository: UserRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: UserRepository) {
        userRepository = repository
    }
    
    func setView(view: EditProfileView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func updateProfile(mobileNumber: String, name: String, birthdate: String, city: String, gender: String, language: String, imageFile : UIImage?){
        self.view?.showloading()
        userRepository.updateProfile(mobileNumber: mobileNumber, name: name, birthdate: birthdate, city: city, gender: gender, language: language, imageFile: imageFile) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.showSuccess(userData: (result?.data)!)
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showValidationError()
            }else if error == NetworkUserRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
//                self.userDefault.removeSession()
            }else if error == NetworkUserRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
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

protocol EditProfileView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSuccess(userData : UserData)
    func showValidationError()
    func showSusspendedMsg(msg : String)
}


