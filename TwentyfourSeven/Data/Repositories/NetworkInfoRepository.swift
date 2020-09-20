//
//  NetworkInfoRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/18/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class NetworkInfoRepository: InfoRepository {
  
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loginPresenter: LoginPresenter!
    let userDefault = UserDefault()
    
    enum ErrorType {
        case none
        case auth
        case network
        case invalidValue
        case serverError
        case generalError
        case controlError
    }
    
    func getPages(slug : String, completionHandler: @escaping (_ resultData : PagesResponse?, _ error : NetworkInfoRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PAGES)/\(slug)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PAGES)/\(slug)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let pagesResponse = PagesResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(pagesResponse, NetworkInfoRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getContactUs(completionHandler: @escaping (_ resultData : ContactUsResponse?, _ error : NetworkInfoRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.CONTACT_US)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.CONTACT_US)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let contactUsResponse = ContactUsResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(contactUsResponse, NetworkInfoRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                }
        }
        
    }
    
    func getHowToUse(completionHandler: @escaping (_ resultData : HowToUseResponse?, _ error : NetworkInfoRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.HOW_TO_USE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.HOW_TO_USE)"
        }
        
        //url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let pagesResponse = HowToUseResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(pagesResponse, NetworkInfoRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getHowToBecomeDelegate(completionHandler: @escaping (_ resultData : HowToUseResponse?, _ error : NetworkInfoRepository.ErrorType) -> ()){
        
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.HOW_BECOME_A_DELGATE)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.HOW_BECOME_A_DELGATE)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let pagesResponse = HowToUseResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(pagesResponse, NetworkInfoRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                }
        }
    }
    
    func getPrayerTimes(completionHandler: @escaping (_ resultData : PrayerTimesResponse?, _ error : NetworkInfoRepository.ErrorType) -> ()){
        var url = ""
        if appDelegate.isRTL {
            url = "\(APIURLs.MAIN_URL)ar/api/v1/\(APIURLs.PRAYER_TIMES)"
        }else{
            url = "\(APIURLs.MAIN_URL)en/api/v1/\(APIURLs.PRAYER_TIMES)"
        }
        
        url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                switch (response.result) {
                case .success(_):
                    print(response.description)
                    let prayerTimesResponse = PrayerTimesResponse(json: response.result.value! as! JSON)!
                    let statusCode = response.response?.statusCode
                    if(statusCode == 200){
                        completionHandler(prayerTimesResponse, NetworkInfoRepository.ErrorType.none)
                    }else if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if statusCode == 409{
                        completionHandler(prayerTimesResponse, NetworkInfoRepository.ErrorType.controlError)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                    
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    print(response.description)
                    if statusCode == 400 || statusCode == 404 {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.invalidValue)
                    }else if (statusCode == 500 || statusCode == 503) {
                        completionHandler(nil, NetworkInfoRepository.ErrorType.serverError)
                    }else if Utils.isConnectedToNetwork(){
                        completionHandler(nil, NetworkInfoRepository.ErrorType.generalError)
                    }else{
                        completionHandler(nil, NetworkInfoRepository.ErrorType.network)
                    }
                }
        }
    }
}

