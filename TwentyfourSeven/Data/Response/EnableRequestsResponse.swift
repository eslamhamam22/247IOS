//
//  EnableRequestsResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class EnableRequestsResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : RequestsActivation?
    
    init() {
        status = false
        data = RequestsActivation()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
