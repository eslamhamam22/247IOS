//
//  VerifyCodeError.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/13/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class RequestCodeError: NSObject, Glossy {
    
    var mobile : String?
    
    override init() {
        mobile = ""
    }
    
    init(mobile : String?) {
        self.mobile = mobile
    }
    
    required init?(json : JSON){
        mobile = Decoder.decode(key: "mobile")(json)
        
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "mobile")(self.mobile)
            ])
    }
}
