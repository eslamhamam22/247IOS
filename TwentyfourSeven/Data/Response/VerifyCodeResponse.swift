//
//  VerifyCodeResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/12/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class VerifyCodeResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : VerifyCodeData?
    
    init() {
        status = false
        data = VerifyCodeData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
