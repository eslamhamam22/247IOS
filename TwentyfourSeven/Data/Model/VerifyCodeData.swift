//
//  VerifyCodeData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/12/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class VerifyCodeData: NSObject, Glossy {
    
    var token : String?
    var refresh_token : String?
    var user : UserData?
    var registeredBefore : Bool?
    var firebase_token: String?
    
    override init() {
        registeredBefore = false
        token = ""
        refresh_token = ""
        firebase_token = ""
        user = UserData()
    }
    
    init(registeredBefore : Bool?, token : String?, refresh_token : String?, user : UserData?, firebase_token: String?) {
        self.registeredBefore = registeredBefore
        self.token = token
        self.refresh_token = refresh_token
        self.user = user
        self.firebase_token = firebase_token
    }
    
    required init?(json : JSON){
        registeredBefore = Decoder.decode(key: "registeredBefore")(json)
        token = Decoder.decode(key: "token")(json)
        refresh_token = Decoder.decode(key: "refresh_token")(json)
        firebase_token = Decoder.decode(key: "firebase_token")(json)
        user = Decoder.decode(decodableForKey: "user")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "token")(self.token),
            Encoder.encode(key: "refresh_token")(self.refresh_token),
            Encoder.encode(key: "firebase_token")(self.firebase_token),
            Encoder.encode(key: "user")(self.user),
            Encoder.encode(key: "registeredBefore")(self.registeredBefore)
            ])
    }
}
