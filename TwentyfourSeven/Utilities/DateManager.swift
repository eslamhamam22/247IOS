//
//  DateManager.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class DateManager {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    func getDateFormatted(dateStr : String , format : String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let date = dateFormatter.date(from: dateStr)
        if date != nil{
            if(appDelegate.isRTL) {
                dateFormatter.locale = NSLocale(localeIdentifier: "ar_EG") as Locale?
            }else{
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            }
            dateFormatter.dateFormat = format
            
            let dateString = dateFormatter.string(from: date!)
            return dateString
        }
        
        return ""
    }
    
    func convertToDateString(date : Date , format : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        dateFormatter.timeZone = TimeZone.current
        
        let dateStr = dateFormatter.string(from: date)
        
        let dateToBeDisplayed = getDateFormatted(dateStr: dateStr, format: format)
        
        return dateToBeDisplayed
    }
}
