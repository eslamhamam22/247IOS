//
//  Notification.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 1/9/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Notification: NSObject, Glossy{
    
    var id : Int?
    var message : String?
    var link_to : String?
    var created_at : String?
    var order : Order?

    override init() {
        id = 0
        message = ""
        link_to = ""
        created_at = ""
        order = Order()
    }
    
    init( id : Int? , message : String? , link_to : String? , created_at : String?, order : Order?) {
        self.id = id
        self.message = message
        self.link_to = link_to
        self.created_at = created_at
        self.order = order
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        message = Decoder.decode(key: "message")(json)
        link_to = Decoder.decode(key: "link_to")(json)
        created_at = Decoder.decode(key: "created_at")(json)
        order = Decoder.decode(decodableForKey: "order")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "message")(self.message),
            Encoder.encode(key: "link_to")(self.link_to),
            Encoder.encode(key: "order")(self.order),
            Encoder.encode(key: "created_at")(self.created_at)
            ])
    }
}
