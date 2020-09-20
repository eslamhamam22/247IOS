//
//  BankAccountsResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class BankAccountsResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : [BankAccount]?
    
    init() {
        status = false
        data =  [BankAccount]()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableArrayForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
