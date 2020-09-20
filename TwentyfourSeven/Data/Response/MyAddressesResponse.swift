//
//  MyAddressesResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class MyAddressesResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [Address]?
    
    init() {
        status = false
        data =  [Address]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
