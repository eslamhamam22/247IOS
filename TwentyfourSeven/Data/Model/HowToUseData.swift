//
//  HowToUseData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/3/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class HowToUseData: NSObject, Glossy{
    
    var title : String?
    var desc : String?
    var id : Int?
    var image : Image?
    
    override init() {
        title = ""
        desc = ""
        id = 0
        image = Image()
    }
    
    init(title : String?, desc : String?, id : Int?, image : Image?) {
        self.title = title
        self.desc = desc
        self.id = id
        self.image = image
    }
    
    required init?(json : JSON){
        title = Decoder.decode(key: "title")(json)
        desc = Decoder.decode(key: "description")(json)
        id = Decoder.decode(key: "id")(json)
        image = Decoder.decode(decodableForKey: "image")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "description")(self.desc),
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "image")(self.image),
            Encoder.encode(key: "title")(self.title)
            ])
    }
}

