//
//  NsData+extention.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
}

enum ImageFormat{
    case Unknown, PNG, JPEG
}


extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else{
            return .Unknown
        }
    }
}
