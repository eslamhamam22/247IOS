//
//  StoresListPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/15/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class StoresListPresenter : Presenter{
    
    var view : StoresListView?
    var placesRepository: PlacesRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var page = 1
    var stores = [Place]()

    init (repository: PlacesRepository) {
        placesRepository = repository
    }
    
    func setView(view: StoresListView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getNearbyStores(category: String, latitude: Double, longitude: Double, next_page_token: String){
        if page == 1{
            self.view?.showloading()
        }
        placesRepository.getNearbyPlaces(category: category, latitude: latitude, longitude: longitude, next_page_token: next_page_token) { (response, error) in
            self.view?.hideLoading()
            if error == NetworkPlacesRepository.ErrorType.none{
                if response?.results != nil{
                    print("count: \((response?.results?.count)!)")
                    if (response?.results?.count)! == 0{
                        self.view?.stopInfinitScroll()
                        if self.stores.count == 0{
                            
                        }
                    }else{
                        if response?.next_page_token != nil{
                            self.stores.append(contentsOf: response!.results!)
                            self.page = self.page+1
                            self.view?.setStores(data: self.stores, nextToken: (response?.next_page_token)!)
                        }else{
                            self.stores.append(contentsOf: response!.results!)
                            self.page = self.page+1
                            self.view?.setStores(data: self.stores, nextToken: "")
                            self.view?.stopInfinitScroll()
                        }
                    }
                }else{
                    self.view?.stopInfinitScroll()
                }
            }else if error == NetworkPlacesRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func getAllStores(category: String, latitude: Double, longitude: Double, next_page_token: String){
        if page == 1{
            self.view?.showloading()
        }
        placesRepository.getAllPlaces(isActive: false, category: category, latitude: latitude, longitude: longitude, next_page_token: next_page_token) { (response, error) in
            
            self.view?.hideLoading()
            if error == NetworkPlacesRepository.ErrorType.none{
                if response?.results != nil{
                    print("count: \((response?.results?.count)!)")
                    if (response?.results?.count)! == 0{
                        self.view?.stopInfinitScroll()
                        if self.stores.count == 0{
                            self.view?.setNoData()
                        }
                    }else{
                        if response?.next_page_token != nil{
                            self.stores.append(contentsOf: response!.results!)
                            self.page = self.page+1
                            self.view?.setStores(data: self.stores, nextToken: (response?.next_page_token)!)
                        }else{
                            self.stores.append(contentsOf: response!.results!)
                            self.page = self.page+1
                            self.view?.setStores(data: self.stores, nextToken: "")
                            self.view?.stopInfinitScroll()
                        }
                    }
                }else{
                    self.view?.stopInfinitScroll()
                }
            }else if error == NetworkPlacesRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkPlacesRepository.ErrorType.invalidValue{
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

protocol StoresListView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func stopInfinitScroll()
    func setStores(data: [Place], nextToken: String)
    func setNoData()
}

