//
//  MyOrdersResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class MyOrdersResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [Order]?
    
    init() {
        status = false
        data = [Order]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
