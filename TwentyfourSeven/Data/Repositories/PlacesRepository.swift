//
//  PlacesRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit


protocol PlacesRepository {
    
    func getNearbyPlaces(category: String, latitude: Double, longitude: Double, next_page_token : String, completionHandler: @escaping (PlacesListResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ())
   
    func getCategories(completionHandler: @escaping (CategoriesResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ())
    
    func getAllPlaces(isActive: Bool, category: String, latitude: Double, longitude: Double, next_page_token : String, completionHandler: @escaping (PlacesListResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ())
    
    func getPlaceDetails(id: String,isStoreLoaded: Bool, completionHandler: @escaping (PlaceDetailsResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ())
    
    func getBlockedAreas(completionHandler: @escaping (BlockedAreaResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ())
}
