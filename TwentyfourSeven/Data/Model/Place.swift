//
//  Place.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Place: NSObject, Glossy {
    
    var icon : String?
    var id : String?
    var name : String?
    var place_id : String?
    var rating : Double?
    var vicinity : String?
    var opening_hours : PlaceOpeningHours?
    var formatted_phone_number : String?
    var geometry : PlaceGeometry?
    var types : [String]?
    var photos : [PlacePhoto]?
    var isValidUrl : Bool?
    
    override init() {
        icon = ""
        id = ""
        name = ""
        place_id = ""
        rating = 0.0
        vicinity = ""
        opening_hours = PlaceOpeningHours()
        formatted_phone_number = ""
        geometry = PlaceGeometry()
        types = [String]()
        photos = [PlacePhoto]()
    }
    
    init(icon : String?, id : String?, name : String?, place_id : String?, rating : Double?, vicinity : String?, opening_hours : PlaceOpeningHours?, formatted_phone_number : String?, geometry : PlaceGeometry?, types : [String]?, photos: [PlacePhoto]?) {
        self.icon = icon
        self.id = id
        self.name = name
        self.place_id = place_id
        self.rating = rating
        self.vicinity = vicinity
        self.opening_hours = opening_hours
        self.formatted_phone_number = formatted_phone_number
        self.geometry = geometry
        self.types = types
        self.photos = photos
    }
    
    required init?(json : JSON){
        vicinity = Decoder.decode(key: "vicinity")(json)
        icon = Decoder.decode(key: "icon")(json)
        id = Decoder.decode(key: "id")(json)
        name = Decoder.decode(key: "name")(json)
        place_id = Decoder.decode(key: "place_id")(json)
        rating = Decoder.decode(key: "rating")(json)
        formatted_phone_number = Decoder.decode(key: "formatted_phone_number")(json)
        opening_hours = Decoder.decode(decodableForKey: "opening_hours")(json)
        geometry = Decoder.decode(decodableForKey: "geometry")(json)
        types = Decoder.decode(key: "types")(json)
        photos = Decoder.decode(decodableArrayForKey: "photos")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "vicinity")(self.vicinity),
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "name")(self.name),
            Encoder.encode(key: "place_id")(self.place_id),
            Encoder.encode(key: "rating")(self.rating),
            Encoder.encode(key: "opening_hours")(self.opening_hours),
            Encoder.encode(key: "formatted_phone_number")(self.formatted_phone_number),
            Encoder.encode(key: "icon")(self.icon),
            Encoder.encode(key: "types")(self.types),
            Encoder.encode(key: "photos")(self.photos),
            Encoder.encode(key: "geometry")(self.geometry)
            ])
    }
}
