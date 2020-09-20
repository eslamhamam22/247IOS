//
//  SocialLoginData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/11/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class SocialLoginData: NSObject, Glossy {
    
    var registeredBefore : Bool?
    
    override init() {
        registeredBefore = false
    }
    
    init(registeredBefore : Bool?) {
        self.registeredBefore = registeredBefore
    }
    
    required init?(json : JSON){
        registeredBefore = Decoder.decode(key: "registeredBefore")(json)
        
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "registeredBefore")(self.registeredBefore)
            ])
    }
}
