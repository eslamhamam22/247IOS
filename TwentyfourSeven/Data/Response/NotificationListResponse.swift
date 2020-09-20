//
//  NotificationListResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 1/9/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class NotificationListResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : NotificationData?
    
    init() {
        status = false
        data =  NotificationData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
