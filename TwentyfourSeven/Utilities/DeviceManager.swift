//
//  DeviceManager.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/31/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

class DeviceManager: NSObject{
    
    func getDeviceName() -> String{
        var name = ""
        // for iphone size
        if UIDevice().userInterfaceIdiom == .phone {
            let height = UIScreen.main.nativeBounds.height
            if height <= 1136{
                name = "iPhone5"
            }else if height == 1334{
                name = "iPhone6"
            }else if height == 2208{
                name = "iPhone6+"
            }else if height == 2436{
                name = "iPhonex"
            }else{
                name = "unknown"
            }
        }
        return name
    }
}



