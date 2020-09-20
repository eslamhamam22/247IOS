//
//  PlaceLocation.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/15/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class PlaceLocation: NSObject, Glossy , NSCoding{
    
    var lat : Double?
    var lng : Double?
    
    override init() {
        lat = 0.0
        lng = 0.0
    }
    
    init(lat : Double?, lng : Double?) {
        self.lat = lat
        self.lng = lng
    }
    
    required init?(json : JSON){
        lat = Decoder.decode(key: "lat")(json)
        lng = Decoder.decode(key: "lng")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "lat")(self.lat),
            Encoder.encode(key: "lng")(self.lng)
            ])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(lng, forKey: "lng")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let lat = aDecoder.decodeObject(forKey: "lat") as? Double
        let lng = aDecoder.decodeObject(forKey: "lng") as? Double
        
        self.init(lat: lat, lng: lng)
    }
    
}
