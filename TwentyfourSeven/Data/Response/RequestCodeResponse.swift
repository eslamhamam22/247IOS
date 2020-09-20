//
//  RequestCodeResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/13/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class RequestCodeResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : String? = ""
    
    init() {
        status = false
        data = ""
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(key: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
