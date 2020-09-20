//
//  UserDefault.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class UserDefault {
    
    static let TOKEN = "user_token"
    static let REFRESH_TOKEN = "refresh_token"
    static let FIREBASE_TOKEN = "firebase_token"
    static let USER = "user"
    static let IS_FIRST_LAUNCH = "is_first_launch"
    static let LANGUAGE_SETTING = "language"
    static let PLAYER_ID = "player_id"
    static let NOTIFICATION_STATUS = "notification_status"
    static let UNSEEN_NOTIFICATION_COUNT = "unseen_notification_count"
    static let LAST_KNOWN_LOCATION = "last_known_location"
    static let LAST_KNOWN_COUNTRY_CODE = "last_known_country_code"
    static let CATEGORIES = "categories"
    static let DEFAULT_CATEGORY = "default_category"
    static let has_app_notif = "has_app_notif"
    static let MAX_NEGATIVE_BALANCE = "MAX_NEGATIVE_BALANCE"
    static let APP_URL = "app_url"

    let mUserDefault = UserDefaults.standard
    
    func setToken(_ token: String?) {
        mUserDefault.set(token, forKey: UserDefault.TOKEN)
        mUserDefault.synchronize()
    }
    
    func getToken() -> String? {
        return mUserDefault.string(forKey: UserDefault.TOKEN)
    }
    
    func setRefreshToken(_ token: String?) {
        mUserDefault.set(token, forKey: UserDefault.REFRESH_TOKEN)
        mUserDefault.synchronize()
    }
    
    func getRefreshToken() -> String? {
        return mUserDefault.string(forKey: UserDefault.REFRESH_TOKEN)
    }
    
    func setFirebaseToken(_ token: String?) {
        mUserDefault.set(token, forKey: UserDefault.FIREBASE_TOKEN)
        mUserDefault.synchronize()
    }
    
    func getFirebaseToken() -> String? {
        return mUserDefault.string(forKey: UserDefault.FIREBASE_TOKEN)
    }
    
    func setUserData(userData : UserData){
        let key = "\(UserDefault.USER)"
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
        mUserDefault.set(encodedData, forKey: key)
        mUserDefault.synchronize()
    }
    
    func getUserData() -> UserData {
        let decodedData  = mUserDefault.object(forKey: UserDefault.USER) as? Data
        if (decodedData != nil) {
            let decodedUserInfo = NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? UserData ?? UserData()
            return decodedUserInfo
        }
        return UserData()
    }
    
    func setLastKnownLocation(location : PlaceLocation){
        let key = "\(UserDefault.LAST_KNOWN_LOCATION)"
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: location)
        mUserDefault.set(encodedData, forKey: key)
        mUserDefault.synchronize()
    }
    
    func getLastKnownLocation() -> PlaceLocation {
        let decodedData  = mUserDefault.object(forKey: UserDefault.LAST_KNOWN_LOCATION) as? Data
        if (decodedData != nil) {
            let decodedUserInfo = NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? PlaceLocation ?? PlaceLocation()
            return decodedUserInfo
        }
        return PlaceLocation()
    }
    
    func setLanguage(_ language: String?) {
        mUserDefault.set(language, forKey: UserDefault.LANGUAGE_SETTING)
        mUserDefault.synchronize()
    }
    
    func getLanguage() -> String? {
        return mUserDefault.string(forKey: UserDefault.LANGUAGE_SETTING)
    }
    
    func setCountryCode(_ countryCode: String?) {
        mUserDefault.set(countryCode, forKey: UserDefault.LAST_KNOWN_COUNTRY_CODE)
        mUserDefault.synchronize()
    }
    
    func getCountryCode() -> String? {
        return mUserDefault.string(forKey: UserDefault.LAST_KNOWN_COUNTRY_CODE)
    }
    
    func setFirstLaunch(_ isFirst: Bool?) {
        mUserDefault.set(isFirst, forKey: UserDefault.IS_FIRST_LAUNCH)
        mUserDefault.synchronize()
    }
    
    func isFirstLaunch() -> Bool? {
        return mUserDefault.bool(forKey: UserDefault.IS_FIRST_LAUNCH)
    }
    
    func setNotificationUnread(_ hasNotification: Bool?) {
        mUserDefault.set(hasNotification, forKey: UserDefault.has_app_notif)
        mUserDefault.synchronize()
    }
    
    func hasNotificationUnread() -> Bool? {
        return mUserDefault.bool(forKey: UserDefault.has_app_notif)
    }
    
    func setPlayerID(_ playerID: String?) {
        mUserDefault.set(playerID, forKey: UserDefault.PLAYER_ID)
        mUserDefault.synchronize()
    }
    
    func getPlayerID() -> String? {
        return mUserDefault.string(forKey: UserDefault.PLAYER_ID)
    }
    
    
    func setCategories(_ categories: [Category]?) {
        let key = "\(UserDefault.CATEGORIES)"
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: categories ?? [categories])
        mUserDefault.set(encodedData, forKey: key)
        mUserDefault.synchronize()
    }
    
    func getCategories() -> [Category]? {
        let decodedData  = mUserDefault.object(forKey: UserDefault.CATEGORIES) as? Data
        if (decodedData != nil) {
            let decodedUserInfo = NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? [Category] ?? [Category]()
            return decodedUserInfo
        }
        return [Category]()
    }
    
    func setDefaultCategory(_ category: Category?) {
        let key = "\(UserDefault.DEFAULT_CATEGORY)"
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: category ?? Category())
        mUserDefault.set(encodedData, forKey: key)
        mUserDefault.synchronize()
    }
    
    func getDefaultCategory() -> Category? {
        let decodedData  = mUserDefault.object(forKey: UserDefault.DEFAULT_CATEGORY) as? Data
        if (decodedData != nil) {
            let decodedUserInfo = NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? Category ?? Category()
            return decodedUserInfo
        }
        return Category()
    }
    
    func setMaximumBalance(balance : Double){
        mUserDefault.set(balance, forKey: UserDefault.MAX_NEGATIVE_BALANCE)
        mUserDefault.synchronize()
    }
    
    func getMaximumBalance() -> Double?{
        return mUserDefault.double(forKey: UserDefault.MAX_NEGATIVE_BALANCE)
    }
    
    func setAppUrl(_ url: String?) {
        mUserDefault.set(url, forKey: UserDefault.APP_URL)
        mUserDefault.synchronize()
    }
    
    func getAppUrl() -> String? {
        return mUserDefault.string(forKey: UserDefault.APP_URL)
    }
    
    func removeSession() {
       
        mUserDefault.removeObject(forKey: UserDefault.TOKEN)
        mUserDefault.removeObject(forKey: UserDefault.LANGUAGE_SETTING)
        mUserDefault.removeObject(forKey: UserDefault.REFRESH_TOKEN)
        mUserDefault.removeObject(forKey: UserDefault.USER)
        mUserDefault.removeObject(forKey: UserDefault.LAST_KNOWN_LOCATION)
        mUserDefault.removeObject(forKey: UserDefault.LAST_KNOWN_COUNTRY_CODE)
        mUserDefault.removeObject(forKey: UserDefault.CATEGORIES)
        mUserDefault.removeObject(forKey: UserDefault.MAX_NEGATIVE_BALANCE)
        mUserDefault.removeObject(forKey: UserDefault.FIREBASE_TOKEN)

        //mUserDefault.removeObject(forKey: UserDefault.PLAYER_ID)


        mUserDefault.synchronize()
        AppDelegate.getInstance().isFromNotifications = false
        AppDelegate.getInstance().loadAndSetRootWindow()
    }
    
    
    
    
    
}




