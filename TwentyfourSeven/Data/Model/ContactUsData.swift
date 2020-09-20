//
//  ContactUsData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class ContactUsData: NSObject, Glossy{
    
    var mobile : String?
    var email : String?
    var fax_number : String?
    var address_en : String?
    var address_ar : String?
    var address_map : String?
    var facebook_url : String?
    var twitter_url : String?
    var google_url : String?
    var site_url : String?
    var instagram_url : String?
    var lat : String?
    var lng : String?

    override init() {
        mobile = ""
        email = ""
        fax_number = ""
        address_en = ""
        address_ar = ""
        address_map = ""
        facebook_url = ""
        twitter_url = ""
        google_url = ""
        site_url = ""
        lat = ""
        lng = ""
        instagram_url = ""
    }
    
    init(mobile : String?, email : String?, fax_number : String?, address_en : String?, address_ar : String?, address_map : String?, facebook_url : String?, twitter_url : String?, google_url : String?, site_url : String?, lat : String?, lng : String?, instagram_url: String?) {
        self.mobile = mobile
        self.email = email
        self.fax_number = fax_number
        self.address_en = address_en
        self.address_ar = address_ar
        self.address_map = address_map
        self.facebook_url = facebook_url
        self.twitter_url = twitter_url
        self.google_url = google_url
        self.instagram_url = instagram_url
        self.site_url = site_url
        self.lat = lat
        self.lng = lng
    }
    
    required init?(json : JSON){
        mobile = Decoder.decode(key: "mobile")(json)
        email = Decoder.decode(key: "email")(json)
        fax_number = Decoder.decode(key: "fax_number")(json)
        address_en = Decoder.decode(key: "address_en")(json)
        address_ar = Decoder.decode(key: "address_ar")(json)
        address_map = Decoder.decode(key: "address_map")(json)
        facebook_url = Decoder.decode(key: "facebook_url")(json)
        twitter_url = Decoder.decode(key: "twitter_url")(json)
        google_url = Decoder.decode(key: "google_url")(json)
        instagram_url = Decoder.decode(key: "instagram_url")(json)
        site_url = Decoder.decode(key: "site_url")(json)
        lat = Decoder.decode(key: "lat")(json)
        lng = Decoder.decode(key: "lng")(json)

    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "mobile")(self.mobile),
            Encoder.encode(key: "email")(self.email),
            Encoder.encode(key: "fax_number")(self.fax_number),
            Encoder.encode(key: "address_en")(self.address_en),
            Encoder.encode(key: "address_ar")(self.address_ar),
            Encoder.encode(key: "address_map")(self.address_map),
            Encoder.encode(key: "facebook_url")(self.facebook_url),
            Encoder.encode(key: "twitter_url")(self.twitter_url),
            Encoder.encode(key: "google_url")(self.google_url),
            Encoder.encode(key: "instagram_url")(self.instagram_url),
            Encoder.encode(key: "lat")(self.lat),
            Encoder.encode(key: "lng")(self.lng),
            Encoder.encode(key: "site_url")(self.site_url)
            ])
    }
}

