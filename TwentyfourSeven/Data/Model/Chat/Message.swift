//
//  Message.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

class Message : NSObject{
    
    var defaultMsg : String?
    var en : String?
    var ar : String?
    
    override init() {
        defaultMsg = ""
        en = ""
        ar = ""
    }
    
    init( defaultMsg : String? , en : String? , ar : String?) {
        self.defaultMsg = defaultMsg
        self.en = en
        self.ar = ar
    }
}
