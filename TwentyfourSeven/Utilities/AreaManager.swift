//
//  AreaManager.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/12/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import GoogleMaps
import Polyline

class AreaManager: NSObject{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func isSelectedPointInBlockedArea(latitude : Double? , longitude : Double?) -> Bool{
        var blockedArea = false
        if latitude != nil && longitude != nil{
            for i in 0..<appDelegate.blockedAreas.count{
                if appDelegate.blockedAreas[i].encoded_path != nil{
                    if GMSPath(fromEncodedPath: appDelegate.blockedAreas[i].encoded_path!) != nil{
                        let path =  GMSPath(path: GMSPath(fromEncodedPath: appDelegate.blockedAreas[i].encoded_path!)!)
                        if GMSGeometryContainsLocation(CLLocationCoordinate2D(latitude:latitude!, longitude: longitude!), path , true){
                            blockedArea = true
                            break
                        }
                    }
                }
            }
        }
        return blockedArea
    }
}

