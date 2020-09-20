//
//  RequestsActivation.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class RequestsActivation: NSObject, Glossy , NSCoding{
    
    var active : Bool?
    
    override init() {
        active = false
    }
    
    init(active : Bool?) {
        self.active = active
    }
    
    required init?(json : JSON){
        active = Decoder.decode(key: "active")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "active")(self.active)
            ])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(active, forKey: "active")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let active = aDecoder.decodeObject(forKey: "active") as? Bool
        self.init(active : active)
    }
}
