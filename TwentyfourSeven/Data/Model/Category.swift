//
//  Category.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/16/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Category: NSObject, Glossy, NSCoding{
    
    var name : String?
    var image : Image?
    var related_categories : String?
    
    override init() {
        name = ""
        image = Image()
        related_categories = ""
    }
    
    init(name: String?, image : Image?, related_categories : String?) {
        self.name = name
        self.image = image
        self.related_categories = related_categories
    }
    
    required init?(json : JSON){
        name = Decoder.decode(key: "name")(json)
        image = Decoder.decode(decodableForKey: "icon")(json)
        related_categories = Decoder.decode(key: "related_category")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "icon")(self.image),
            Encoder.encode(key: "related_category")(self.related_categories),
            Encoder.encode(key: "name")(self.name)
            ])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(image, forKey: "icon")
        aCoder.encode(related_categories, forKey: "related_category")
        aCoder.encode(name, forKey: "name")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let image = aDecoder.decodeObject(forKey: "icon") as? Image
        let related_categories = aDecoder.decodeObject(forKey: "related_category") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        
        self.init(name: name, image: image, related_categories: related_categories)
    }
}

