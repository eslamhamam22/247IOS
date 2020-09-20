//
//  MyComplaintsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class MyComplaintsPresenter : Presenter{
    
    var view : MyComplaintsView?
    var userRepository: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var page = 1
    var limit = 10
    var complaints = [Complaint]()
    
    init (userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func setView(view: MyComplaintsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getMyComplaints(){
        if self.page == 1{
            self.view?.showloading()
        }
        userRepository.getComplaints(page: page, limit: limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data != nil{
                        if( result?.data!.count == 0 && self.complaints.count == 0) {
                            self.view?.stopInfinitScroll()
                            self.view?.showNoData()
                        } else if (self.complaints.count > 0 && result?.data!.count == 0  ) {
                            self.view?.stopInfinitScroll()
                        }else {
                            self.complaints.append(contentsOf: result!.data!)
                            self.page = self.page+1
                            self.view?.setData(complaints: self.complaints)
                        }
                    }
                }
                
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
                self.userRepository.generalRefreshToken()
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

protocol MyComplaintsView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func stopInfinitScroll()
    func setData(complaints: [Complaint])
    func showNoData()
}
