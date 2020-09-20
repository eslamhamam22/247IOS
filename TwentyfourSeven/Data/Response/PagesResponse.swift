//
//  PagesResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/19/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class PagesResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : PagesData?
    
    init() {
        status = false
        data = PagesData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
