//
//  ErrorResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/30/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class ErrorData: NSObject, Glossy {
    
    var defaultError : String?
    var mobile : String?
    var code: String?
    var couponCode: String?
    
    override init() {
        defaultError = ""
        mobile = ""
        code = ""
        couponCode = ""
    }
    
    init(defaultError : String?, mobile : String?, code: String?, couponCode: String?) {
        self.defaultError = defaultError
        self.mobile = mobile
        self.code = code
        self.couponCode = couponCode
    }
    
    required init?(json : JSON){
        defaultError = Decoder.decode(key: "default")(json)
        mobile = Decoder.decode(key: "mobile")(json)
        code = Decoder.decode(key: "code")(json)
        couponCode = Decoder.decode(key: "couponCode")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "default")(self.defaultError),
            Encoder.encode(key: "code")(self.code),
            Encoder.encode(key: "couponCode")(self.couponCode),
            Encoder.encode(key: "mobile")(self.mobile)
            ])
    }
}
