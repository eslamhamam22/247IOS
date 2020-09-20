//
//  PlacePhoto.swift
//  TwentyfourSeven
//
//  Created by Salma on 8/15/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class PlacePhoto: NSObject, Glossy{
    
    var photo_reference : String?

    
    override init() {
        photo_reference = ""
    }
    
    init(photo_reference : String?) {
        self.photo_reference = photo_reference
    }
    
    required init?(json : JSON){
        photo_reference = Decoder.decode(key: "photo_reference")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "photo_reference")(self.photo_reference)
            ])
    }
}
