//
//  CarDetailsData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/8/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class CarDetailsData: NSObject, Glossy{
    
    var car_details : String?
    var id : Int?
    var car_front_image : Image?
    var car_back_image : Image?
    var driver_license_image : Image?
    var national_id_image : Image?
    var active : Bool?
    
    override init() {
        car_details = ""
        id = 0
        car_front_image = Image()
        car_back_image = Image()
        driver_license_image = Image()
        national_id_image = Image()
        active = false
    }
    
    init(car_details : String?, id : Int?, car_front_image : Image?, car_back_image : Image?, driver_license_image : Image?, national_id_image : Image?, active : Bool?) {
        self.car_details = car_details
        self.id = id
        self.car_front_image = car_front_image
        self.car_back_image = car_back_image
        self.driver_license_image = driver_license_image
        self.national_id_image = national_id_image
        self.active = active
    }
    
    required init?(json : JSON){
        car_details = Decoder.decode(key: "car_details")(json)
        id = Decoder.decode(key: "id")(json)
        active = Decoder.decode(key: "active")(json)
        national_id_image = Decoder.decode(decodableForKey: "national_id_image")(json)
        car_front_image = Decoder.decode(decodableForKey: "car_front_image")(json)
        driver_license_image = Decoder.decode(decodableForKey: "driver_license_image")(json)
        car_back_image = Decoder.decode(decodableForKey: "car_back_image")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "car_details")(self.car_details),
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "active")(self.active),
            Encoder.encode(key: "car_front_image")(self.car_front_image),
            Encoder.encode(key: "driver_license_image")(self.driver_license_image),
            Encoder.encode(key: "car_back_image")(self.car_back_image),
            Encoder.encode(key: "national_id_image")(self.national_id_image)
            ])
    }
}

