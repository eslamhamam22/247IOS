//
//  StoresListByNearestPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class StoresListByNearestPresenter : Presenter{
    
    var view : StoresListByNearestView?
    var placesRepository: PlacesRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var nearByStores = [Place]()
    var activeStores = [Place]()
    var page = 1
    var nearby_next_page_token = ""
    
    init (repository: PlacesRepository) {
        placesRepository = repository
    }
    
    func setView(view: StoresListByNearestView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getNearByStores(category: String, latitude: Double, longitude: Double){
        self.view?.showloading()
        placesRepository.getNearbyPlaces(category: category, latitude: latitude, longitude: longitude, next_page_token: "") { (response, error) in
            if error == NetworkPlacesRepository.ErrorType.none{
                if response?.results != nil{
                    self.nearByStores = (response?.results)!
                    if response?.next_page_token != nil{
                        self.nearby_next_page_token = (response?.next_page_token)!
                    }
                    self.getActiveStores(category: category, latitude: latitude, longitude: longitude, nextToken: "")
                }
                
            }else if error == NetworkPlacesRepository.ErrorType.serverError{
                self.view?.hideLoading()
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.generalError{
                self.view?.hideLoading()
                self.view?.showGeneralError()
            }else{
                self.view?.hideLoading()
                self.view?.showNetworkError()
            }
        }
    }
    
    func getActiveStores(category: String, latitude: Double, longitude: Double, nextToken: String){
        
        placesRepository.getAllPlaces(isActive: true, category: category, latitude: latitude, longitude: longitude, next_page_token: nextToken) { (response, error) in
            self.view?.hideLoading()
            if error == NetworkPlacesRepository.ErrorType.none{
                if response?.results != nil{
                    if (response?.results?.count)! == 0{
                        self.view?.stopInfinitScroll()
                        self.view?.setStores(nearestStores: self.nearByStores, activeStores: self.activeStores, nextToken: "", nearby_next_page_token: self.nearby_next_page_token)
                    }else{
                        if response?.next_page_token != nil{
                            self.activeStores.append(contentsOf: response!.results!)
                            self.page = self.page+1
                            self.view?.setStores(nearestStores: self.nearByStores, activeStores: self.activeStores, nextToken: (response?.next_page_token)!, nearby_next_page_token: self.nearby_next_page_token)
                        }else{
                            self.activeStores.append(contentsOf: response!.results!)
                            self.page = self.page+1
                            self.view?.setStores(nearestStores: self.nearByStores, activeStores: self.activeStores, nextToken: "", nearby_next_page_token: self.nearby_next_page_token)
                            self.view?.stopInfinitScroll()
                        }
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
    
    func resetData(){
        self.page = 1
        self.activeStores = [Place]()
        self.nearByStores = [Place]()
        self.nearby_next_page_token = ""
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol StoresListByNearestView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setStores(nearestStores: [Place], activeStores: [Place], nextToken: String, nearby_next_page_token: String)
    func stopInfinitScroll()
}


