//
//  TransactionListResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class TransactionListResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [Transaction]?
    
    init() {
        status = false
        data =  [Transaction]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
