//
//  CancellationReasonsResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 5/8/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class CancellationReasonsResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [CancellationReason]?
    
    init() {
        status = false
        data =  [CancellationReason]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
