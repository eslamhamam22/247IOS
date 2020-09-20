//
//  PaymentDataResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/15/20.
//  Copyright © 2020 Objects. All rights reserved.
//

import Foundation
import Gloss

class PaymentDataResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : PaymentData?
    
    init() {
        status = false
        data =  PaymentData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
