//
//  UserData.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import Gloss

class UserData: NSObject, Glossy , NSCoding{
    
    var id : Int?
    var mobile : String?
    var gender : String?
    var lang : String?
    var name : String?
    var city : String?
    var image : Image?
    var birthdate : String?
    var has_delegate_request : Bool?
    var is_delegate: Bool?
    var notifications_enabled : Bool?
    var unseen_notifications_count : Int?
    var delegate_details : RequestsActivation?
    var rating: Double?
    var delegate_rating: Double?
    var balance : Double?
    var delegate_orders_count: Int?
    var orders_count: Int?
    
    override init() {
        id = 0
        mobile = ""
        gender = ""
        lang = ""
        name = ""
        city = ""
        image = Image()
        birthdate = ""
        has_delegate_request = false
        is_delegate = false
        notifications_enabled = false
        unseen_notifications_count = 0
        delegate_details = RequestsActivation()
        rating = 0
        delegate_rating = 0
        balance = 0
        delegate_orders_count = 0
        orders_count = 0
    }
    
    init(id : Int?, mobile : String?, gender : String?, lang : String?, name : String?, city : String?, image : Image?, birthdate : String?, has_delegate_request : Bool?, is_delegate: Bool? ,  notifications_enabled : Bool? , unseen_notifications_count : Int? , delegate_details : RequestsActivation?, rating: Double?, delegate_rating: Double? , balance : Double?, delegate_orders_count: Int?, orders_count: Int?) {
        self.id = id
        self.mobile = mobile
        self.gender = gender
        self.lang = lang
        self.name = name
        self.city = city
        self.image = image
        self.birthdate = birthdate
        self.has_delegate_request = has_delegate_request
        self.is_delegate = is_delegate
        self.notifications_enabled = notifications_enabled
        self.unseen_notifications_count = unseen_notifications_count
        self.delegate_details = delegate_details
        self.rating = rating
        self.delegate_rating = delegate_rating
        self.balance = balance
        self.delegate_orders_count = delegate_orders_count
        self.orders_count = orders_count
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        mobile = Decoder.decode(key: "mobile")(json)
        gender = Decoder.decode(key: "gender")(json)
        lang = Decoder.decode(key: "lang")(json)
        name = Decoder.decode(key: "name")(json)
        city = Decoder.decode(key: "city")(json)
        image = Decoder.decode(decodableForKey: "image")(json)
        has_delegate_request = Decoder.decode(key: "has_delegate_request")(json)
        is_delegate = Decoder.decode(key: "is_delegate")(json)
        notifications_enabled = Decoder.decode(key: "notifications_enabled")(json)
        unseen_notifications_count = Decoder.decode(key: "unseen_notifications_count")(json)
        delegate_details = Decoder.decode(decodableForKey: "delegate_details")(json)
        rating = Decoder.decode(key: "rating")(json)
        delegate_rating = Decoder.decode(key: "delegate_rating")(json)
        balance = Decoder.decode(key: "balance")(json)
        delegate_orders_count = Decoder.decode(key: "delegate_orders_count")(json)
        orders_count = Decoder.decode(key: "orders_count")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "mobile")(self.mobile),
            Encoder.encode(key: "gender")(self.gender),
            Encoder.encode(key: "name")(self.name),
            Encoder.encode(key: "city")(self.city),
            Encoder.encode(key: "image")(self.image),
            Encoder.encode(key: "birthdate")(self.birthdate),
            Encoder.encode(key: "has_delegate_request")(self.has_delegate_request),
            Encoder.encode(key: "is_delegate")(self.is_delegate),
            Encoder.encode(key: "lang")(self.lang),
            Encoder.encode(key: "notifications_enabled")(self.notifications_enabled),
            Encoder.encode(key: "unseen_notifications_count")(self.unseen_notifications_count),
            Encoder.encode(key: "rating")(self.rating),
            Encoder.encode(key: "delegate_rating")(self.delegate_rating),
            Encoder.encode(key: "delegate_details")(self.delegate_details),
            Encoder.encode(key: "delegate_orders_count")(self.delegate_orders_count),
            Encoder.encode(key: "orders_count")(self.orders_count),
            Encoder.encode(key: "balance")(self.balance)

            ])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(mobile, forKey: "mobile")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(lang, forKey: "lang")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(birthdate, forKey: "birthdate")
        aCoder.encode(is_delegate, forKey: "is_delegate")
        aCoder.encode(has_delegate_request, forKey: "has_delegate_request")
        aCoder.encode(notifications_enabled, forKey: "notifications_enabled")
        aCoder.encode(unseen_notifications_count, forKey: "unseen_notifications_count")
        aCoder.encode(delegate_details, forKey: "delegate_details")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(delegate_rating, forKey: "delegate_rating")
        aCoder.encode(balance, forKey: "balance")
        aCoder.encode(orders_count, forKey: "orders_count")
        aCoder.encode(delegate_orders_count, forKey: "delegate_orders_count")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? Int
        let mobile = aDecoder.decodeObject(forKey: "mobile") as? String
        let gender = aDecoder.decodeObject(forKey: "gender") as?  String
        let lang = aDecoder.decodeObject(forKey: "namlange") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let city = aDecoder.decodeObject(forKey: "city") as? String
        let image = aDecoder.decodeObject(forKey: "image") as? Image
        let birthdate = aDecoder.decodeObject(forKey: "birthdate") as? String
        let has_delegate_request = aDecoder.decodeObject(forKey: "has_delegate_request") as? Bool
        let is_delegate = aDecoder.decodeObject(forKey: "is_delegate") as? Bool
        let rating = aDecoder.decodeObject(forKey: "rating") as? Double
        let delegate_rating = aDecoder.decodeObject(forKey: "delegate_rating") as? Double
        let notifications_enabled = aDecoder.decodeObject(forKey: "notifications_enabled") as? Bool
        let unseen_notifications_count = aDecoder.decodeObject(forKey: "unseen_notifications_count") as? Int
        let delegate_details = aDecoder.decodeObject(forKey: "delegate_details") as? RequestsActivation
        let balance = aDecoder.decodeObject(forKey: "balance") as? Double
        let delegate_orders_count = aDecoder.decodeObject(forKey: "delegate_orders_count") as? Int
        let orders_count = aDecoder.decodeObject(forKey: "orders_count") as? Int

        self.init(id: id, mobile: mobile, gender: gender, lang: lang, name: name, city: city, image: image, birthdate: birthdate, has_delegate_request: has_delegate_request, is_delegate: is_delegate, notifications_enabled: notifications_enabled, unseen_notifications_count: unseen_notifications_count , delegate_details : delegate_details, rating: rating, delegate_rating: delegate_rating , balance : balance, delegate_orders_count: delegate_orders_count, orders_count: orders_count)
    }
   
}

