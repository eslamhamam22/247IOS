//
//  TrackingManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/12/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Firebase
import FirebaseDatabase
import GeoFire
import GoogleMaps
import Polyline

class TrackingManager: NSObject{
    
    var databaseRef : DatabaseReference!
    var delegatesLocationsRef : DatabaseReference!
    var delegateRef : DatabaseReference!
    
    weak var viewContoller : UIViewController!
    var pathPoints = [CLLocationCoordinate2D]()
    var pickupLocation = CLLocationCoordinate2D()
    var destinationLocation = CLLocationCoordinate2D()
    var isBeforePickup = true
    
    func initRefernces(delegateID: Int, viewContoller : UIViewController, pickupLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D){
        databaseRef = Database.database().reference().child(APIURLs.DATABASE_TABEL)
        delegatesLocationsRef = databaseRef.child("delegates_locations")
        delegateRef = delegatesLocationsRef.child("\(String(describing: delegateID))")
        
        self.viewContoller = viewContoller
        self.pickupLocation = pickupLocation
        self.destinationLocation = destinationLocation
    }
    
    func setDeliveryStatus(isBeforePickup: Bool){
        self.isBeforePickup = isBeforePickup
    }
    
    func getDelegateCurrentLocation(delegateID: Int, viewContoller : UIViewController){
        self.viewContoller = viewContoller
        let geoFire = GeoFire(firebaseRef: delegatesLocationsRef)
        geoFire.getLocationForKey("\(String(describing: delegateID))") { (location, error) in
            if (error != nil) {
                print("An error occurred getting the location for \"firebase-hq\": \(error!.localizedDescription)")
            } else if (location != nil) {
                print("Location for \"firebase-hq\" is [\(location!.coordinate.latitude), \(location!.coordinate.longitude)]")
                self.drawDelegateRoute(location: location!)
            } else {
                print("GeoFire does not contain a location for \"firebase-hq\"")
            }
        }
    }
    
    func getUpdatedOnDelegateLocation(){
        print("getUpdatedOnDelegateLocation")
        if delegateRef != nil{
            delegateRef.observe(.value, with: {(snapshot) in
                if snapshot.exists(){
                    for location in snapshot.children {
                        let locationSnapShot = location as! DataSnapshot
                        if locationSnapShot.key == "l"{
                            if let coordinates = locationSnapShot.value as? [Double]{
                                print("coordinates: \(coordinates)")
                                if coordinates.count == 2{
                                    print(coordinates[0])
                                    print(coordinates[1])
                                    let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
                                    self.drawDelegateRoute(location: location)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func getLastDelegateLocation(){
        print("getLastDelegateLocation")
        delegateRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for location in snapshot.children {
                    let locationSnapShot = location as! DataSnapshot
                    if locationSnapShot.key == "l"{
                        if let coordinates = locationSnapShot.value as? [Double]{
                            print("coordinates: \(coordinates)")
                            if coordinates.count == 2{
                                print(coordinates[0])
                                print(coordinates[1])
                                let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
                                self.drawDelegateRoute(location: location)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func drawDelegateRoute(location: CLLocation){
        if let userOrderDetailsVC = self.viewContoller as? UserOrderDetailsVC{
            if userOrderDetailsVC.isViewLoaded{
                userOrderDetailsVC.updateCarOnMAp(location: location)
            }
        }else if let chatVC = self.viewContoller as? ChatVC{
            if chatVC.isViewLoaded{
                chatVC.updateDelegateLocation(location: location)
            }
        }
    }
    
    func removeDrivedRoute(polylineStr: String, delegateLocation: CLLocation) -> String{
        // convert the polyline to array of coordinates
        let polyline = Polyline(encodedPolyline: polylineStr)
        if polyline.locations != nil{
            pathPoints = polyline.coordinates!
        }
        
//        for point in pathPoints{
//            print(GMSGeometryDistance(delegateLocation.coordinate, point))
//        }
        
        var newPathPoints = [CLLocationCoordinate2D]()
        newPathPoints.append(delegateLocation.coordinate)
        var noPointAdded = false
        // if not moved from his point ar witll be delegate location only
        for i in 1..<pathPoints.count{
            let index = detectDelegateBetweenTwoLocations(delegateLocation: delegateLocation.coordinate, firstLocation: pathPoints[i - 1], secondLocation: pathPoints[i], indexFirst: i - 1, indexSecond: i)
            if index != -1{
                var myCount = 0
                for point in pathPoints{
                    if myCount > index {
                        newPathPoints.append(point)
                        noPointAdded = true
                    }
                    myCount += 1
                }
                break
            }
        }
        
        //if no points added in the array because no points should be removed .. so add all path points
        if !noPointAdded{
            newPathPoints.append(contentsOf: pathPoints)
        }
        
        //return the result of conversion of coordinates to path
        return encodeCoordinates(newPathPoints)
    }
    
    func detectDelegateBetweenTwoLocations(delegateLocation: CLLocationCoordinate2D, firstLocation: CLLocationCoordinate2D, secondLocation: CLLocationCoordinate2D, indexFirst: Int, indexSecond: Int) -> Int{
        
        let twoPointsDistance = GMSGeometryDistance(firstLocation, secondLocation)
        let fromDelegateToFirst = GMSGeometryDistance(firstLocation, delegateLocation)
        let fromDelegateToSecond = GMSGeometryDistance(delegateLocation, secondLocation)
        
        if twoPointsDistance > fromDelegateToFirst &&  twoPointsDistance > fromDelegateToSecond{
            print("remove first point with distance \(fromDelegateToFirst)")
            return indexFirst
        }
        return -1
    }
    
    func checkIsDelegateArrivedToPickup(delegateLocation: CLLocation) -> Bool{
        let twoPointsDistance = GMSGeometryDistance(delegateLocation.coordinate, pickupLocation)
        if twoPointsDistance < 15{
            //
            print("reach to pickup")
            isBeforePickup = false
            return true
        }else{
            print("still on his way")
            isBeforePickup = true
            return false
        }
    }
    
    func changeDelegatePolyline(delegateLocation: CLLocation){
        if let userOrderDetailsVC = self.viewContoller as? UserOrderDetailsVC{
            if userOrderDetailsVC.isViewLoaded{
                userOrderDetailsVC.setAfterPickupDelegateLocation(location: delegateLocation)
            }
        }
    }
    
    func polyLineWithEncodedString(encodedString: String) -> [CLLocationCoordinate2D] {
        var myRoutePoints=[CLLocationCoordinate2D]()
        let bytes = (encodedString as NSString).utf8String
        var idx: Int = 0
        var latitude: Double = 0
        var longitude: Double = 0
        while (idx < encodedString.lengthOfBytes(using: String.Encoding.utf8)) {
            var byte = 0
            var res = 0
            var shift = 0
            repeat {
                byte = Int(bytes![idx]) - 63
                idx += 1
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            let deltaLat = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            latitude += Double(deltaLat)
            
            shift = 0
            res = 0
            repeat {
                byte = Int(bytes![idx]) - 63
                idx += 1
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            let deltaLon = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            longitude += Double(deltaLon)
            
            myRoutePoints.append(CLLocation(latitude: Double(latitude * 1E-5), longitude: Double(longitude * 1E-5)).coordinate)
        }
        return myRoutePoints
    }
    
    func getDistanceValue(fromLocationLat: Double, fromLocationLng: Double, toLocationLat: Double, toLocationLng: Double)-> Double{
        let location1 = CLLocation(latitude:fromLocationLat , longitude: fromLocationLng)
        let location2 = CLLocation(latitude: toLocationLat, longitude: toLocationLng)
        
        let distanceInMeters = location1.distance(from: location2)
        print("distanceInMeters: \(distanceInMeters)")
        return distanceInMeters
    }
    
    func removeObservers(){
        delegateRef.removeAllObservers()
        databaseRef.removeAllObservers()
        delegatesLocationsRef.removeAllObservers()
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
}

