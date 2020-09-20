//
//  PlaceOpeningHours.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class PlaceOpeningHours: NSObject, Glossy {
    
    var open_now : Bool?
    var weekday_text : [String]?
    
    
    override init() {
        open_now = false
        weekday_text = [String]()
    }
    
    init(open_now : Bool?, weekday_text : [String]?) {
        self.open_now = open_now
        self.weekday_text = weekday_text
    }
    
    required init?(json : JSON){
        open_now = Decoder.decode(key: "open_now")(json)
        weekday_text = Decoder.decode(key: "weekday_text")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "open_now")(self.open_now),
            Encoder.encode(key: "weekday_text")(self.weekday_text)
            ])
    }
}
