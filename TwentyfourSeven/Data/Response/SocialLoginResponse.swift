//
//  LoginResponse.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class SocialLoginResponse : Gloss.Decodable {
    
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
