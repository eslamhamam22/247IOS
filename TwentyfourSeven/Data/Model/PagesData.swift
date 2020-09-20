//
//  PagesData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/19/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class PagesData: NSObject, Glossy{
    
    var content : String?
    var name : String?
    var slug : String?
    var id : Int?
    var image : Image?
    
    override init() {
        content = ""
        name = ""
        slug = ""
        id = 0
        image = Image()
    }
    
    init(content : String?, name: String, slug: String, id: Int, image : Image?) {
        self.content = content
        self.name = name
        self.slug = slug
        self.id = id
        self.image = image
    }
    
    required init?(json : JSON){
        content = Decoder.decode(key: "content")(json)
        name = Decoder.decode(key: "name")(json)
        slug = Decoder.decode(key: "slug")(json)
        id = Decoder.decode(key: "id")(json)
        image = Decoder.decode(decodableForKey: "image")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "content")(self.content),
            Encoder.encode(key: "slug")(self.slug),
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "image")(self.image),
            Encoder.encode(key: "name")(self.name)
            ])
    }
}

