//
//  NetworkPlacesRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class NetworkPlacesRepository : PlacesRepository {
    
    //    let api_key = "AIzaSyC9r-OKjB0bWnBiHpDlod1FjEyB_Ytakh8"
    let WEB_API_KEY = AppKeys.WEB_API_KEY
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()

    enum ErrorType {
        case none
        case network
        case invalidValue
        case serverError
        case generalError
        case auth
        case suspended
        case controlError

    }
    
    func getNearbyPlaces(category: String, latitude: Double, longitude: Double,next_page_token : String, completionHandler: @escaping (PlacesListResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ()) {
        
        var url =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&rankby=distance&key=\(WEB_API_KEY)"
        
//        var url =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=25.624261,42.352832&rankby=distance&key=\(WEB_API_KEY)"

        
        if appDelegate.isRTL {
            url += "&language=ar"
        }else{
            url += "&language=en"
        }
        
        if category != ""{
            url += "&types=\(category)"
        }
        
        if next_page_token != ""{
            url += "&pagetoken=\(next_page_token)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request( url,  method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let placesListResponse = PlacesListResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(placesListResponse, NetworkPlacesRepository.ErrorType.none)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getAllPlaces(isActive: Bool, category: String, latitude: Double, longitude: Double, next_page_token : String, completionHandler: @escaping (PlacesListResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ()){
        
        var url =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&rankby=prominence&radius=5000&key=\(WEB_API_KEY)"
        
//        var url =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=25.624261,42.352832&rankby=prominence&radius=5000&key=\(WEB_API_KEY)"

        if category != ""{
            url += "&types=\(category)"
        }
        
        if isActive{
            url += "&opennow=true"
        }
        
        if appDelegate.isRTL {
            url += "&language=ar"
        }else{
            url += "&language=en"
        }
        
        if next_page_token != ""{
            url += "&pagetoken=\(next_page_token)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request( url,  method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let placesListResponse = PlacesListResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(placesListResponse, NetworkPlacesRepository.ErrorType.none)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                }
        }
    }
    
    
    func getPlaceDetails(id: String,isStoreLoaded: Bool, completionHandler: @escaping (PlaceDetailsResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ()){
        
        //            url =  "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&fields=name,rating,formatted_phone_number,opening_hours,geometry,icon,formatted_address&key=\(WEB_API_KEY)"

        
        var url = ""
        if isStoreLoaded{
            url =  "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&fields=name,photo,opening_hours&key=\(WEB_API_KEY)"
        }else{
            url =  "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&fields=name,opening_hours,geometry,icon,vicinity,type,photo,formatted_address&key=\(WEB_API_KEY)"
        }
        
        if appDelegate.isRTL {
            url += "&language=ar"
        }else{
            url += "&language=en"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request( url,  method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let placeDetailsResponse = PlaceDetailsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(placeDetailsResponse, NetworkPlacesRepository.ErrorType.none)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                }
        }
    }
    
    
    
    func getCategories(completionHandler: @escaping (CategoriesResponse?, _ error : NetworkPlacesRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CATEGORIES)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CATEGORIES)"
        }
        
        //url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let categoriesResponse = CategoriesResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(categoriesResponse, NetworkPlacesRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                }
        }
    }
    
    
    func getBlockedAreas(completionHandler: @escaping (BlockedAreaResponse?, NetworkPlacesRepository.ErrorType) -> ()) {
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.BLOCKED_AREAS)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.BLOCKED_AREAS)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let blockedAreaResponse = BlockedAreaResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
            
                    if(statusCode == 200){
                        completionHandler(blockedAreaResponse, NetworkPlacesRepository.ErrorType.none)
                    }else if statusCode == 422{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.invalidValue)
                    }else if statusCode == 401{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.auth)
                    }else if statusCode == 403{
                        completionHandler(blockedAreaResponse, NetworkPlacesRepository.ErrorType.suspended)
                    }else if statusCode == 409{
                        completionHandler(blockedAreaResponse, NetworkPlacesRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 422{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.invalidValue)
                    }else if statusCode == 400 || statusCode == 401{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.auth)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkPlacesRepository.ErrorType.network)
                    }
                }
        }
    }
}

