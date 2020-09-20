//
//  ContactUsResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class ContactUsResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : ContactUsData?
    
    init() {
        status = false
        data = ContactUsData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
