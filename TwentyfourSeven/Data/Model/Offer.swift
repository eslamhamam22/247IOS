//
//  Offer.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/19/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Offer: NSObject, Glossy {
    
    var id : Int?
    var commission : Double?
    var cost : Double?
    var vat : Double?
    var delegate : UserData?
    var delegate_address : String?
    var dist_to_delivery : Double?
    var dist_to_pickup : Double?
    
    override init() {
        id = 0
        commission = 0.0
        cost = 0.0
        vat = 0.0
        delegate = UserData()
        delegate_address = ""
        dist_to_delivery = 0.0
        dist_to_pickup = 0.0
    }
    
    init(id : Int?, commission : Double?, cost : Double?, vat : Double?, delegate : UserData?, delegate_address : String?, dist_to_delivery : Double?, dist_to_pickup : Double?) {
        self.id = id
        self.commission = commission
        self.cost = cost
        self.vat = vat
        self.delegate = delegate
        self.delegate_address = delegate_address
        self.dist_to_delivery = dist_to_delivery
        self.dist_to_pickup = dist_to_pickup
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        commission = Decoder.decode(key: "commission")(json)
        cost = Decoder.decode(key: "cost")(json)
        vat = Decoder.decode(key: "vat")(json)
        delegate = Decoder.decode(decodableForKey: "delegate")(json)
        delegate_address = Decoder.decode(key: "delegate_address")(json)
        dist_to_delivery = Decoder.decode(key: "dist_to_delivery")(json)
        dist_to_pickup = Decoder.decode(key: "dist_to_pickup")(json)

    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "vat")(self.vat),
            Encoder.encode(key: "cost")(self.cost),
            Encoder.encode(key: "delegate")(self.delegate),
            Encoder.encode(key: "delegate_address")(self.delegate_address),
            Encoder.encode(key: "dist_to_delivery")(self.dist_to_delivery),
            Encoder.encode(key: "dist_to_pickup")(self.dist_to_pickup),
            Encoder.encode(key: "commission")(self.commission)
            ])
    }
}
