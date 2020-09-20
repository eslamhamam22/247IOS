//
//  CategoryBanner.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/17/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class CategoriesBanner: NSObject, Glossy {
    
    var image : Image?
    
    override init() {
        image = Image()
    }
    
    init(image : Image?) {
        self.image = image
    }
    
    required init?(json : JSON){
        image = Decoder.decode(decodableForKey: "image")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "image")(self.image)
            ])
    }
}
