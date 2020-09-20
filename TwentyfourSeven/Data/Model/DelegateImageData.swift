//
//  DelegateImageData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class DelegateImageData: NSObject, Glossy{
    
    var type : String?
    var id : Int?
    var image : Image?
    
    override init() {
        type = ""
        id = 0
        image = Image()
    }
    
    init(type : String?, id : Int?, image : Image?) {
        self.type = type
        self.id = id
        self.image = image
    }
    
    required init?(json : JSON){
        type = Decoder.decode(key: "type")(json)
        id = Decoder.decode(key: "id")(json)
        image = Decoder.decode(decodableForKey: "image")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "type")(self.type),
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "image")(self.image)
            ])
    }
}

