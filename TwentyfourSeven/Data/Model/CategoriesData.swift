//
//  Categories.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/17/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class CategoriesData: NSObject, Glossy {
    
    var category : [Category]?
    var banner : CategoriesBanner?
    var default_category : Category?

    override init() {
        category = [Category]()
        banner = CategoriesBanner()
        default_category = Category()
    }
    
    init(category : [Category]?, banner : CategoriesBanner?, default_category : Category?) {
        self.category = category
        self.banner = banner
        self.default_category = default_category
    }
    
    required init?(json : JSON){
        category = Decoder.decode(decodableArrayForKey: "categories")(json)
        banner = Decoder.decode(decodableForKey: "banner")(json)
        default_category = Decoder.decode(decodableForKey: "default_category")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "categories")(self.category),
            Encoder.encode(key: "default_category")(self.default_category),
            Encoder.encode(key: "banner")(self.banner)
            ])
    }
}
