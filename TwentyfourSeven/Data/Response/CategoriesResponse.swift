//
//  CategoriesResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/16/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class CategoriesResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : CategoriesData?
    
    init() {
        status = false
        data = CategoriesData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
