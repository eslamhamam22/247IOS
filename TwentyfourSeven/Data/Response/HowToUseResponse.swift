//
//  HowToUseResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/3/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class HowToUseResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [HowToUseData]?
    
    init() {
        status = false
        data =  [HowToUseData]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
