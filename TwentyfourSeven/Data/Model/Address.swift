//
//  Address.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//


import Foundation
import Gloss

class Address: NSObject, Glossy {

    var id : Int?
    var address_title : String?
    var address : String?
    var lat : Double?
    var lng : Double?

    override init() {
        id = 0
        address_title  = ""
        address = ""
        lat = 0.0
        lng = 0.0
    }
    
    init(id : Int?, address_title : String?, address : String?, lat : Double?, lng : Double?) {
        self.id = id
        self.address_title = address_title
        self.address = address
        self.lat = lat
        self.lng = lng

    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        address_title = Decoder.decode(key: "address_title")(json)
        address = Decoder.decode(key: "address")(json)
        lat = Decoder.decode(key: "lat")(json)
        lng = Decoder.decode(key: "lng")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "address_title")(self.address_title),
            Encoder.encode(key: "address")(self.address),
            Encoder.encode(key: "lng")(self.lng),
            Encoder.encode(key: "lat")(self.lat)
            ])
    }
}
