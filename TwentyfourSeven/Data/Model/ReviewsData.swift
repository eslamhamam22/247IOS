//
//  ReviewsData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class ReviewsData: NSObject, Glossy{
    
    var reviews : [Review]?
    var user : UserData?
    
    override init() {
        reviews = [Review]()
        user = UserData()
    }
    
    init(reviews : [Review]?, user : UserData?) {
        self.reviews = reviews
        self.user = user
    }
    
    required init?(json : JSON){
        reviews = Decoder.decode(decodableArrayForKey: "reviews")(json)
        user = Decoder.decode(decodableForKey: "user")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "reviews")(self.reviews),
            Encoder.encode(key: "user")(self.user)
            ])
    }
    
}

