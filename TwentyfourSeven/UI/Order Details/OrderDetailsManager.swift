//
//  OrderDetailsManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class OrderDetailsManager:NSObject{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let timerMaxMin = 4
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setShadow(selectedView : UIView){
        selectedView.layer.borderColor = UIColor.lightGray.cgColor
        selectedView.layer.borderWidth = 0
        selectedView.layer.masksToBounds = false
        selectedView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectedView.layer.shadowRadius = 3
        selectedView.layer.shadowOpacity = 0.1
    }
    
    func daysBetweenDates(startDate: Date, endDate: Date) -> Int{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        if components.day != nil{
            return components.day!
        }else{
            return 0
        }
    }
    
    func prodTimeString(time: TimeInterval) -> String {
        let prodHours = Int(time) / 3600 % 60
        let prodMinutes = Int(time) / 60 % 60
        let prodSeconds = Int(time) % 60
        if prodHours != 0{
            return String(format: "%02d:%02d:%02d",prodHours, prodMinutes, prodSeconds)
        }
        return String(format: "%02d:%02d", prodMinutes, prodSeconds)
    }
    
    func getMinutesPassed(time: TimeInterval) -> Int{
        let prodMinutes = Int(time) / 60 % 60
        return prodMinutes
    }
    
    func isSearchForDelagtesValid(time: TimeInterval) -> Bool{
        let prodHours = Int(time) / 3600 % 60
        let prodMinutes = Int(time) / 60 % 60
        let downMinutes = timerMaxMin - prodMinutes
//        print("downMinutes: \(downMinutes)")
        if prodHours == 0{
            if downMinutes <= timerMaxMin && downMinutes >= 0{
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    func getCountDownString(time: TimeInterval) -> String {
        let prodMinutes = Int(time) / 60 % 60
        let prodSeconds = Int(time) % 60
        
        var downMinutes = timerMaxMin - prodMinutes
        var downSeconds = 60 - prodSeconds

        if downSeconds == 60{
            downSeconds = 0
            downMinutes += 1
        }
        return String(format: "%02d:%02d", downMinutes, downSeconds)
    }
    
    func heightForLable(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.font = Utils.customDefaultFont(14)
        label.sizeToFit()
        
        return label.frame.height
    }
    
    func getFormattedDate(dateTxt : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //Your date format
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let date = dateFormatter.date(from: dateTxt)
        if date != nil{
            if(appDelegate.isRTL) {
                dateFormatter.locale = NSLocale(localeIdentifier: "ar_EG") as Locale?
            }else{
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            }
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            let dateString = dateFormatter.string(from: date!)
            return dateString
        }
        
        return ""
    }
    
    func getDistance(fromLocationLat: Double, fromLocationLng: Double, toLocationLat: Double, toLocationLng: Double)-> String{
        let location1 = CLLocation(latitude:fromLocationLat , longitude: fromLocationLng)
        let location2 = CLLocation(latitude: toLocationLat, longitude: toLocationLng)
        
        let distanceInMeters = location1.distance(from: location2)
        print("distanceInMeters: \(distanceInMeters)")
        if Int(distanceInMeters) > 1000{
            return "\(Int(distanceInMeters/1000)) \("Km".localized())"
        }else{
            return "\(Int(distanceInMeters)) \("M".localized())"
        }
    }
    
    func getDistanceValue(fromLocationLat: Double, fromLocationLng: Double, toLocationLat: Double, toLocationLng: Double)-> Double{
        let location1 = CLLocation(latitude:fromLocationLat , longitude: fromLocationLng)
        let location2 = CLLocation(latitude: toLocationLat, longitude: toLocationLng)
        
        let distanceInMeters = location1.distance(from: location2)
        print("distanceInMeters: \(distanceInMeters)")
        return distanceInMeters
    }
}
