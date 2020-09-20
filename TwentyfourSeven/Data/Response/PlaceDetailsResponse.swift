//
//  PlaceDetailsResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class PlaceDetailsResponse : Gloss.Decodable {
    
    var status : String? = ""
    var error : ErrorData?
    var results : Place?
    var next_page_token : String?
    
    init() {
        status = ""
        results = Place()
        error = ErrorData()
        next_page_token = ""
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.results = Decoder.decode(decodableForKey: "result")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
        self.next_page_token = Decoder.decode(key: "next_page_token")(json)
        
    }
    
    
}
