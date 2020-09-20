//
//  Utils.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Utils {
    
    static func customDefaultFont(_ fontSize: CGFloat) -> UIFont{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.isRTL) {
            print("\(fontSize)")
            return UIFont(name: "BahijTheSansArabic-Plain", size: fontSize)!
        } else {
            return UIFont(name: "Montserrat-Regular", size: fontSize)!
        }
    }
    
    static func customBoldFont(_ fontSize: CGFloat) -> UIFont{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.isRTL) {
            //let   engfontSize = 1
            return UIFont(name: "BahijTheSansArabicBold", size: CGFloat(fontSize))!
        } else {
            //let   arafontSize =  22
            return UIFont(name: "Montserrat-Bold", size: CGFloat(fontSize))!
        }
    }
  
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        //        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        //            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        //        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static func isValidatePhoneNumber(_ number: String) -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        if !number.isEmpty && number.rangeOfCharacter(from: numberCharacters) == nil {
            return true
        }
        return false
    }
}
