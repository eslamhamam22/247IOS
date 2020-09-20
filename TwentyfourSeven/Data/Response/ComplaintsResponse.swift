//
//  ComplaintResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class ComplaintsResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [Complaint]?
    
    init() {
        status = false
        data =  [Complaint]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
