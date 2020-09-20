//
//  MyReviewsResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class MyReviewsResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : ReviewsData?
    
    init() {
        status = false
        data = ReviewsData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
