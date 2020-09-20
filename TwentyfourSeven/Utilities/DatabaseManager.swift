//
//  DatabaseManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/13/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Toaster
import GeoFire
import FirebaseDatabase
import Polyline

class DatabaseManager: NSObject{

    let locationManager = LocationManager()
    let userDefault = UserDefault()
    let updatedTime = 10
    let minDistance = 20
    var isCheckedBefore = false
    
    var oldLocation = CLLocation()
    var newLocation = CLLocation()
    
    //for testing
    var databaseRef : DatabaseReference!
    var delegatesLocationsRef : DatabaseReference!
    var delegateRef : DatabaseReference!
    var pathPoints = [CLLocation]()

    @objc func checkDelagateLocation(){
        if userDefault.getToken() != nil{
            if userDefault.getUserData().is_delegate != nil{
                if userDefault.getUserData().is_delegate!{
                    if userDefault.getUserData().delegate_details != nil{
                        if userDefault.getUserData().delegate_details?.active != nil{
                            if (userDefault.getUserData().delegate_details?.active)!{
                                print("delegate active")
                                if !isCheckedBefore{
                                    //first time to check create timer
                                    sendDelagateLocation()
                                    sendDelagateLocationTimer()
                                    isCheckedBefore = true
                                }else{
                                    // send delegate location
                                    sendDelagateLocation()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sendDelagateLocationTimer(){
        print("send delegate Location")
        Timer.scheduledTimer(timeInterval: TimeInterval(updatedTime), target: self, selector: (#selector(checkDelagateLocation)), userInfo: nil, repeats: true)
    }
    
    @objc func sendDelagateLocation(){
        print("send delegate Location")
        requestDelegateCurrentLocation()
    }
    
    func requestDelegateCurrentLocation(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDelegateCurrentLocation), name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)

        locationManager.determineMyCurrentLocation(isNeedCountryCode: false)
    }
    
    @objc func getDelegateCurrentLocation(){
        if locationManager.locationStatus == "denied" || locationManager.locationStatus == ""{
            print("no location enabled")
//            Toast(text: "permissionDenied".localized()).show()
        }else{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)
            
            newLocation = locationManager.location
            
            if oldLocation.coordinate.latitude != 0.0 &&  oldLocation.coordinate.longitude != 0.0{
                let distance = getDistanceValue(fromLocationLat: oldLocation.coordinate.latitude, fromLocationLng: oldLocation.coordinate.longitude, toLocationLat: locationManager.location.coordinate.latitude, toLocationLng: locationManager.location.coordinate.longitude)
                if Int(distance) >= minDistance{
                    // distance is greatest than min distance so update it in firebase
                    sendDelegateCurrentLocation(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
                }
            }else{
                //first time set location
                sendDelegateCurrentLocation(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
            }
        }
    }
    
    func sendDelegateCurrentLocation(latitude: Double, longitude: Double){
        print("delegate latitude: \(latitude) delegate longitude: \(longitude)")
        let databaseRef = Database.database().reference().child(APIURLs.DATABASE_TABEL)
        // geofire table
        let delegateLocationRef = databaseRef.child("delegates_locations")
        let geoFire = GeoFire(firebaseRef: delegateLocationRef)
        if userDefault.getUserData().id != nil{
            geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: "\(String(describing: userDefault.getUserData().id!))")
            oldLocation = CLLocation(latitude: latitude, longitude: longitude)
            drawDelegateRoute(location: oldLocation)
        }
        changeUpdatedAt()
    }

    func changeUpdatedAt(){
        let databaseRef = Database.database().reference().child(APIURLs.DATABASE_TABEL)
        let delegatesRef = databaseRef.child("delegates")
        if userDefault.getUserData().id != nil{
            delegateRef = delegatesRef.child(String(describing: userDefault.getUserData().id!))
            let updatedAtRef = delegateRef.child("updated_at")
            updatedAtRef.setValue(ServerValue.timestamp())
            updateDelegateRouteInFirebase(delegatesRef: delegatesRef)
        }
    }
    
    func updateDelegateRouteInFirebase(delegatesRef : DatabaseReference){
        // check if delegate has order
        delegatesRef.child(String(describing: userDefault.getUserData().id!)).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists(){
                if snapshot.hasChild("order"){
                    print("true order exist")
                    let orderRef = self.delegateRef.child("order")
                    orderRef.child("status").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            if let status = snapshot.value as? String{
                                print(status)
                                if status == "delivery_in_progress" || status == "in_progress"{
                                    //after assign and before complete order
                                    self.getTheSavedRoutePath(orderRef: orderRef)
                                }
                            }
                        }
                    })
                }else{
                    print("false order doesn't exist")
                }
            }
        })
    }
    
    func getTheSavedRoutePath(orderRef: DatabaseReference){
        orderRef.child("path").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                if let path = snapshot.value as? String{
                    //convert the saved path string to array of coordinates
                    let polyline = Polyline(encodedPolyline: path)
                    if polyline.locations != nil{
                        self.pathPoints = polyline.locations!
                        //add the new location value
                        self.pathPoints.append(self.newLocation)
                    }else{
                        //add the new location value
                        self.pathPoints.append(self.newLocation)
                    }
                }else{
                    //add the new location value
                    self.pathPoints.append(self.newLocation)
                }
            }else{
                //add the new location value
                self.pathPoints.append(self.newLocation)
            }
            self.insertNewDelegatePath(orderRef: orderRef)
        })
    }
    
    func insertNewDelegatePath(orderRef: DatabaseReference){
        let pathRef = orderRef.child("path")
        pathRef.setValue(encodeLocations(pathPoints))
    }
    
    func drawDelegateRoute(location: CLLocation){
        if let navView = self.topMostController() as?  UINavigationController {
            if let view = navView.topViewController as? DelegateOrderDetailsVC{
                view.updateCarOnMAp(location: location)
            }
        }
    }
    
//    func initRefernces(delegateID: Int){
//        databaseRef = Database.database().reference().child(APIURLs.DATABASE_TABEL)
//        delegatesLocationsRef = databaseRef.child("delegates_locations")
//        delegateRef = delegatesLocationsRef.child("\(String(describing: delegateID))")
//
//    }
//
//    func getUpdatedOnDelegateLocation(){
//        print("getUpdatedOnDelegateLocation")
//        delegateRef.observe(.value, with: {(snapshot) in
//            if snapshot.exists(){
//                for location in snapshot.children {
//                    let locationSnapShot = location as! DataSnapshot
//                    if locationSnapShot.key == "l"{
//                        if let coordinates = locationSnapShot.value as? [Double]{
//                            print("coordinates: \(coordinates)")
//                            if coordinates.count == 2{
//                                print(coordinates[0])
//                                print(coordinates[1])
//                                let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
//                                self.drawDelegateRoute(location: location)
//                            }
//                        }
//                    }
//                }
//            }
//        })
//    }
    
    func getDistanceValue(fromLocationLat: Double, fromLocationLng: Double, toLocationLat: Double, toLocationLng: Double)-> Double{
        let location1 = CLLocation(latitude:fromLocationLat , longitude: fromLocationLng)
        let location2 = CLLocation(latitude: toLocationLat, longitude: toLocationLng)
        
        let distanceInMeters = location1.distance(from: location2)
        print("distanceInMeters: \(distanceInMeters)")
        return distanceInMeters
    }
    
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
}
