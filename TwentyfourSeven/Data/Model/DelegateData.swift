//
//  DelegateData.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class DelegateData: NSObject, Glossy {
    
    var id : Int?
    var name : String?
    var image : Image?
    var delegate_rating: Double?
    var mobile: String?
    
    override init() {
        id = 0
        name = ""
        image = Image()
        delegate_rating = 0.0
        mobile = ""
    }
    
    init(id : Int?, name : String?, image : Image?, delegate_rating: Double?, mobile: String?) {
        self.id = id
        self.name = name
        self.image = image
        self.delegate_rating = delegate_rating
        self.mobile = mobile
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        name = Decoder.decode(key: "name")(json)
        image = Decoder.decode(decodableForKey: "image")(json)
        delegate_rating = Decoder.decode(key: "delegate_rating")(json)
        mobile = Decoder.decode(key: "mobile")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "image")(self.image),
            Encoder.encode(key: "delegate_rating")(self.delegate_rating),
            Encoder.encode(key: "mobile")(self.mobile),
            Encoder.encode(key: "name")(self.name)
            ])
    }
}
