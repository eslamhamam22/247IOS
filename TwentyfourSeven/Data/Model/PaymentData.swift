//
//  PaymentData.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/15/20.
//  Copyright © 2020 Objects. All rights reserved.
//

import Foundation
import Gloss

class PaymentData: NSObject, Glossy{
    
    var checkout_id : String?
    var result_url : String?
    var html : String?

    override init() {
        checkout_id = ""
        result_url = ""
        html = ""
    }
    
    init( checkout_id : String? , result_url : String? , html : String?) {
        self.checkout_id = checkout_id
        self.result_url = result_url
        self.html = html
    }
    
    required init?(json : JSON){
        result_url = Decoder.decode(key: "redirect_url")(json)
        checkout_id = Decoder.decode(key: "checkout_id")(json)
        html = Decoder.decode(key: "html")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "checkout_id")(self.checkout_id),
            Encoder.encode(key: "redirect_url")(self.result_url),
            Encoder.encode(key: "html")(self.html)
            ])
    }
}
