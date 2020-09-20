//
//  StoreDetailsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class StoreDetailsPresenter : Presenter{
    
    var view : StoreDetailsView?
    var placesRepository: PlacesRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    
    init (repository: PlacesRepository) {
        placesRepository = repository
    }
    
    func setView(view: StoreDetailsView) {
        weak var weakView = view
        self.view = weakView
    }
    
    
    func getStoreDetails(id: String, isStoreLoaded: Bool){
        if !isStoreLoaded {
            self.view?.showloading()
        }
        placesRepository.getPlaceDetails(id: id, isStoreLoaded: isStoreLoaded) { (response, error) in
            self.view?.hideLoading()
            if error == NetworkPlacesRepository.ErrorType.none{
                if response?.results != nil{
                    self.view?.setStoreData(store: (response?.results)!)
                }
            }else if !isStoreLoaded{
                if error == NetworkPlacesRepository.ErrorType.serverError{
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
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol StoreDetailsView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func setStoreData(store: Place)
}

