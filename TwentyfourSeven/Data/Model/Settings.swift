//
//  Settings.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/27/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Settings: NSObject, Glossy{
    
    var max_negative_delegate_wallet : Double?
    var blocked_areas : [BlockedArea]?
    var app_link: String?
    
    override init() {
        max_negative_delegate_wallet = 0.0
        blocked_areas = [BlockedArea]()
        app_link = ""
    }
    
    init( max_negative_delegate_wallet : Double? , blocked_areas : [BlockedArea]?, app_link: String?) {
        self.max_negative_delegate_wallet = max_negative_delegate_wallet
        self.blocked_areas = blocked_areas
        self.app_link = app_link
    }
    
    required init?(json : JSON){
        max_negative_delegate_wallet = Decoder.decode(key: "max_negative_delegate_wallet")(json)
        blocked_areas = Decoder.decode(decodableArrayForKey: "blocked_areas")(json)
        app_link = Decoder.decode(key: "app_link")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "max_negative_delegate_wallet")(self.max_negative_delegate_wallet),
            Encoder.encode(key: "app_link")(self.app_link),
            Encoder.encode(key: "blocked_areas")(self.blocked_areas)
            ])
    }
}
