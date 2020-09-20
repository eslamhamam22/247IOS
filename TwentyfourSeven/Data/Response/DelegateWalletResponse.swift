//
//  DelegateWalletResponse.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class DelegateWalletResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : DelegateWalletInfo?
    
    init() {
        status = false
        data =  DelegateWalletInfo()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
