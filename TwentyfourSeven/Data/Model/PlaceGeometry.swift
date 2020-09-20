//
//  PlaceGeometry.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/15/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class PlaceGeometry: NSObject, Glossy {
    
    var location : PlaceLocation?
    
    override init() {
        location = PlaceLocation()
    }
    
    init(location : PlaceLocation?) {
        self.location = location
    }
    
    required init?(json : JSON){
        location = Decoder.decode(decodableForKey: "location")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "location")(self.location)
            ])
    }
}
