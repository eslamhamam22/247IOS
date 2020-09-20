//
//  Complaint.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Complaint: NSObject, Glossy{
    
    var id : Int?
    var created_at : String?
    var title: String?
    var desc: String?
    var related_order : Order?
    var status: String?

    override init() {
        id = 0
        created_at = ""
        related_order = Order()
        desc = ""
        title = ""
        status = ""
    }
    
    init(id : Int?, created_at : String?, title: String?, desc: String?, related_order : Order?, status: String?) {
        self.id = id
        self.created_at = created_at
        self.related_order = related_order
        self.desc = desc
        self.title = title
        self.status = status
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        related_order = Decoder.decode(decodableForKey: "related_order")(json)
        created_at = Decoder.decode(key: "created_at")(json)
        title = Decoder.decode(key: "title")(json)
        status = Decoder.decode(key: "status")(json)
        desc = Decoder.decode(key: "description")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "related_order")(self.related_order),
            Encoder.encode(key: "title")(self.title),
            Encoder.encode(key: "status")(self.status),
            Encoder.encode(key: "description")(self.desc),
            Encoder.encode(key: "created_at")(self.created_at)
            ])
    }
}
