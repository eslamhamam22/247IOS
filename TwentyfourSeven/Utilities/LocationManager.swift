//
//  LocationManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/13/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces
import Toaster

class LocationManager : NSObject , CLLocationManagerDelegate{
    
    var userDefault = UserDefault()
    var locationManager:CLLocationManager!
    var city = ""
    var countryCode = ""
    var locationStatus = ""
    var location = CLLocation()
    var isNeedCountryCode = true
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        self.location = location
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
        self.setLastKnowLoaction()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)

        if isNeedCountryCode{
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                if error == nil{
                    guard let addressDict = placemarks?[0].addressDictionary else {
                        return
                    }
                    guard let placemark = placemarks?[0] else {
                        return
                    }
                    if placemark.isoCountryCode != nil{
                        print(placemark.isoCountryCode!)
                        self.countryCode = placemark.isoCountryCode!
                        self.userDefault.setCountryCode(placemark.isoCountryCode)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
                    }
                    if let city = addressDict["State"] as? String {
                        print(city)
                        self.city = city
                    }
                }else{
                    self.city = "Error"
                    self.countryCode = "Error"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
                    
                }
            })
        }
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error \(error)")
        self.city = "Error"
        self.countryCode = "Error"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)

    }
    
    func determineMyCurrentLocation(isNeedCountryCode: Bool) {
        self.isNeedCountryCode = isNeedCountryCode
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
       
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
            self.locationStatus = "authorizedWhenInUse"
            break
        case .authorizedAlways:
            print("authorizedAlways")
            locationManager.startUpdatingLocation()
            self.locationStatus = "authorizedWhenInUse"
            break
        case .denied:
            print("denied")
            locationManager.requestAlwaysAuthorization()
            self.locationStatus = "denied"
            break
        case .notDetermined:
            print("notDetermined")
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            print("restricted")
            locationManager.requestAlwaysAuthorization()
            break
        }
    }
    
    func setLastKnowLoaction() {
        let location = PlaceLocation(lat: self.location.coordinate.latitude, lng: self.location.coordinate.longitude)
        userDefault.setLastKnownLocation(location: location)
    }
    
    func isLocationServicesAvailable()-> Bool{
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                return true
            }
        } else {
            print("Location services are not enabled")
            return false
        }
    }
    
    func isLocationServicesDetermined() -> Bool{
        
        return  !(CLLocationManager.authorizationStatus()  == .notDetermined)
    }
    
    func requestLocationPermission(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}
