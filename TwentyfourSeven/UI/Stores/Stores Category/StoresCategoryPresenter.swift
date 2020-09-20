//
//  StoresCategoryPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/13/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class StoresCategoryPresenter : Presenter{
    
    var view : StoresCategoryView?
    var placesRepository: PlacesRepository!
    var userRepoistory: UserRepository!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: PlacesRepository , userRepoistory: UserRepository) {
        placesRepository = repository
        self.userRepoistory = userRepoistory
    }
    
    func setView(view: StoresCategoryView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getStoresCategory(){
        self.view?.showloading()
        placesRepository.getCategories { (result, error) in
            self.view?.hideLoading()
            if error == NetworkPlacesRepository.ErrorType.none{
//                if self.userDefault.getToken() != nil{
                    self.getBlockedAreas(result: result)
//                }else{
//                    if result?.data != nil{
//                        if result?.data?.category != nil{
//                            self.view?.setData(data: (result?.data?.category)!, banner: result?.data?.banner?.image, defaultCategory: result?.data?.default_category)
//                        }
//                    }
//
//                }
            }else if error == NetworkPlacesRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func getBlockedAreas(result : CategoriesResponse?){
        self.view?.showloading()
        placesRepository.getBlockedAreas { (blockedResult, error) in
            self.view?.hideLoading()
            if error == NetworkPlacesRepository.ErrorType.none{
                if let blockedData = blockedResult?.data{
                    if let blockedAreas =  blockedData.blocked_areas{
                        self.appDelegate.blockedAreas = blockedAreas
                    }
                    
                    if let maximumNegativeAmount = blockedData.max_negative_delegate_wallet{
                        self.userDefault.setMaximumBalance(balance: maximumNegativeAmount)
                    }
                    if let url = blockedData.app_link{
                        self.userDefault.setAppUrl(url)
                    }
                    
                }
                if result?.data != nil{
                    if result?.data?.category != nil{
                        self.view?.setData(data: (result?.data?.category)!, banner: result?.data?.banner?.image, defaultCategory: result?.data?.default_category)
                    }
                }
                
                
            }else if error == NetworkPlacesRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.auth{
                self.userRepoistory.generalRefreshToken()
            }else if error == NetworkPlacesRepository.ErrorType.suspended{
                //                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkPlacesRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkPlacesRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.generalError{
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

protocol StoresCategoryView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setData(data: [Category], banner: Image?, defaultCategory: Category?)
}




