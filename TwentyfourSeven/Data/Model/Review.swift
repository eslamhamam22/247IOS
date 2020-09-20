//
//  Review.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Review: NSObject, Glossy{
    
    var id : Int?
    var created_at : String?
    var created_by : UserData?
    var rating: Int?
    var comment: String?
    
    override init() {
        id = 0
        created_at = ""
        created_by = UserData()
        rating = 0
        comment = ""
    }
    
    init( id : Int?, created_at : String?, created_by : UserData?, rating: Int?, comment: String?) {
        self.id = id
        self.created_at = created_at
        self.created_by = created_by
        self.rating = rating
        self.comment = comment
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        created_by = Decoder.decode(decodableForKey: "created_by")(json)
        created_at = Decoder.decode(key: "created_at")(json)
        rating = Decoder.decode(key: "rating")(json)
        comment = Decoder.decode(key: "comment")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "created_by")(self.created_by),
            Encoder.encode(key: "rating")(self.rating),
            Encoder.encode(key: "comment")(self.comment),
            Encoder.encode(key: "created_at")(self.created_at)
            ])
    }
}
