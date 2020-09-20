//
//  BlockedArea.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/12/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class BlockedArea: NSObject, Glossy{
    
    var id : Int?
    var encoded_path : String?
    
    override init() {
        id = 0
        encoded_path = ""
    }
    
    init( id : Int? , encoded_path : String?) {
        self.id = id
        self.encoded_path = encoded_path
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        encoded_path = Decoder.decode(key: "encoded_path")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "encoded_path")(self.encoded_path)
            ])
    }
}
