//
//  File.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class MyReviewsPresenter : Presenter{
    
    var view : MyReviewsView?
    var userRepository: UserRepository!
    var delegateRepository: DelegateRepository!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var page = 1
    var limit = 10
    var reviews = [Review]()
    
    init (userRepository: UserRepository, delegateRepository: DelegateRepository) {
        self.userRepository = userRepository
        self.delegateRepository = delegateRepository
    }
    
    func setView(view: MyReviewsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func resetData(){
        self.page = 1
        self.reviews.removeAll()
    }
    
    func getUserReviews(){
        if self.page == 1{
            self.view?.showloading()
        }
        var id = 0
        if userDefault.getUserData().id != nil{
            id = userDefault.getUserData().id!
        }
        userRepository.getUserReviews(id: id, page: page, limit: limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.reviews != nil{
                        if( result?.data!.reviews!.count == 0 && self.reviews.count == 0) {
                            self.view?.stopInfinitScroll()
                            self.view?.showNoData()
                        } else if (self.reviews.count > 0 && result?.data!.reviews!.count == 0  ) {
                            self.view?.stopInfinitScroll()
                        }else {
                            self.reviews.append(contentsOf: result!.data!.reviews!)
                            self.page = self.page+1
                            self.view?.setData(reviews: self.reviews)
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
    
    func getDelegateReviews(){
        if self.page == 1{
            self.view?.showloading()
        }
        var id = 0
        if userDefault.getUserData().id != nil{
            id = userDefault.getUserData().id!
        }

        delegateRepository.getDelegateReviews(id: id, page: page, limit: limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if result?.data != nil{
                    if result?.data?.reviews != nil{
                        if( result?.data!.reviews!.count == 0 && self.reviews.count == 0) {
                            self.view?.stopInfinitScroll()
                            self.view?.showNoData()
                        } else if (self.reviews.count > 0 && result?.data!.reviews!.count == 0  ) {
                            self.view?.stopInfinitScroll()
                        }else {
                            self.reviews.append(contentsOf: result!.data!.reviews!)
                            self.page = self.page+1
                            self.view?.setData(reviews: self.reviews)
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

protocol MyReviewsView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func stopInfinitScroll()
    func setData(reviews: [Review])
    func showNoData()
}

