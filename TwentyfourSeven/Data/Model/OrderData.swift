//
//  OrderData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/18/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class OrderData: NSObject, Glossy{
    
    var order : Order?
    var free_commission: Bool?
    
    override init() {
        order = Order()
        free_commission = false
    }
    
    init(order : Order?, free_commission: Bool?) {
        self.order = order
        self.free_commission = free_commission
    }
    
    required init?(json : JSON){
        order = Decoder.decode(decodableForKey: "order")(json)
        free_commission = Decoder.decode(key: "free_commission")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "order")(self.order),
            Encoder.encode(key: "free_commission")(self.free_commission)
            ])
    }
    
}

