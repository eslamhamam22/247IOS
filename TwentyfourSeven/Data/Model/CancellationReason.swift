//
//  CancellationReason.swift
//  TwentyfourSeven
//
//  Created by Salma  on 5/8/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class CancellationReason: NSObject, Glossy{
    
    var id : Int?
    var title: String?
    
    override init() {
        id = 0
        title = ""
    }
    
    init(id : Int?, title: String?) {
        self.id = id
        self.title = title
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        title = Decoder.decode(key: "title")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "title")(self.title),
            ])
    }
}
