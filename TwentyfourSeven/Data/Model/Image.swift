//
//  Image.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/17/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class Image: NSObject, Glossy , NSCoding{
    
    var big : String?
    var medium : String?
    var small : String?
    var banner : String?

    
    override init() {
        big = ""
        medium = ""
        small = ""
        banner = ""
    }
    
    init( big : String?, medium : String?, small : String?, banner : String?) {
        self.big = big
        self.medium = medium
        self.small = small
        self.banner = banner

    }
    
    required init?(json : JSON){
        big = Decoder.decode(key: "big")(json)
        medium = Decoder.decode(key: "medium")(json)
        small = Decoder.decode(key: "small")(json)
        banner = Decoder.decode(key: "banner")(json)

    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "big")(self.big),
            Encoder.encode(key: "medium")(self.medium),
            Encoder.encode(key: "small")(self.small),
            Encoder.encode(key: "banner")(self.banner)
            ])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(big, forKey: "big")
        aCoder.encode(medium, forKey: "medium")
        aCoder.encode(small, forKey: "small")
        aCoder.encode(banner, forKey: "banner")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let big = aDecoder.decodeObject(forKey: "big") as? String
        let medium = aDecoder.decodeObject(forKey: "medium") as? String
        let small = aDecoder.decodeObject(forKey: "small") as? String
        let banner = aDecoder.decodeObject(forKey: "banner") as? String

        self.init(big: big, medium: medium, small: small, banner: banner)
    }
    
}

