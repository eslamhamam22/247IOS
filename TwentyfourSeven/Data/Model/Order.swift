//
//  Order.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Order: NSObject, Glossy{
    
    var id : Int?
    var status : String?
    var delegate : DelegateData?
    var store_name : String?
    var from_address : String?
    var to_address : String?
    var created_at : String?
    var desc : String?
    var images : [DelegateImageData]?
    var from_lat : Double?
    var from_lng : Double?
    var to_lat : Double?
    var to_lng : Double?
    var finance_settings : FinanceSettings?
    var offers : [Offer]?
    var user : UserData?
    var search_delegates_result : Int?
    var delivery_price: Double?
    var vat: Double?
    var commission: Double?
    var item_price: Double?
    var is_rated: Bool?
    var fromType: Int?
    var actual_paid: Double?
    var total_price: Double?
    var search_delegates_started_at: String?
    var cancel_reason: CancellationReason?
    var delivery_duration: Int?
    var discount: Double?
    
    override init() {
        id = 0
        status = ""
        delegate = DelegateData()
        store_name = ""
        from_address = ""
        to_address = ""
        created_at = ""
        desc = ""
        images = [DelegateImageData]()
        from_lat = 0.0
        from_lng = 0.0
        to_lat = 0.0
        to_lng = 0.0
        finance_settings = FinanceSettings()
        offers = [Offer]()
        user = UserData()
        search_delegates_result = 0
        delivery_price = 0.0
        vat = 0.0
        commission = 0.0
        item_price = 0.0
        is_rated = false
        fromType = 0
        actual_paid = 0.0
        total_price = 0.0
        search_delegates_started_at = ""
        cancel_reason = CancellationReason()
        delivery_duration = 0
        discount = 0.0
    }
    
    init(  id : Int? , status : String? , delegate : DelegateData? , store_name : String? , from_address : String?,  to_address : String? , created_at : String?, desc : String?, images : [DelegateImageData]?, from_lat : Double?, from_lng : Double?, to_lat : Double?, to_lng : Double?, finance_settings : FinanceSettings?, offers : [Offer]?, user : UserData?, search_delegates_result : Int?, delivery_price: Double?, vat: Double?, commission: Double?, item_price: Double?, is_rated: Bool?, fromType: Int?, actual_paid: Double?, total_price: Double?, search_delegates_started_at: String?, cancel_reason: CancellationReason?, delivery_duration: Int?, discount: Double?) {
        self.id = id
        self.status = status
        self.delegate = delegate
        self.store_name = store_name
        self.from_address = from_address
        self.to_address = to_address
        self.created_at = created_at
        self.desc = desc
        self.images = images
        self.from_lat = from_lat
        self.from_lng = from_lng
        self.to_lat = to_lat
        self.to_lng = to_lng
        self.finance_settings = finance_settings
        self.offers = offers
        self.user = user
        self.search_delegates_result = search_delegates_result
        self.delivery_price = delivery_price
        self.vat = vat
        self.commission = commission
        self.item_price = item_price
        self.is_rated = is_rated
        self.fromType = fromType
        self.actual_paid = actual_paid
        self.total_price = total_price
        self.search_delegates_started_at = search_delegates_started_at
        self.cancel_reason = cancel_reason
        self.delivery_duration = delivery_duration
        self.discount = discount
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        status = Decoder.decode(key: "status")(json)
        delegate = Decoder.decode(decodableForKey: "delegate")(json)
        store_name = Decoder.decode(key: "store_name")(json)
        from_address = Decoder.decode(key: "from_address")(json)
        to_address = Decoder.decode(key: "to_address")(json)
        created_at = Decoder.decode(key: "created_at")(json)
        desc = Decoder.decode(key: "description")(json)
        images = Decoder.decode(decodableArrayForKey: "images")(json)
        from_lat = Decoder.decode(key: "from_lat")(json)
        from_lng = Decoder.decode(key: "from_lng")(json)
        to_lat = Decoder.decode(key: "to_lat")(json)
        to_lng = Decoder.decode(key: "to_lng")(json)
        finance_settings = Decoder.decode(decodableForKey: "finance_settings")(json)
        offers = Decoder.decode(decodableArrayForKey: "offers")(json)
        user = Decoder.decode(decodableForKey: "created_by")(json)
        search_delegates_result = Decoder.decode(key: "search_delegates_result")(json)
        delivery_price = Decoder.decode(key: "delivery_price")(json)
        vat = Decoder.decode(key: "vat")(json)
        commission = Decoder.decode(key: "commission")(json)
        item_price = Decoder.decode(key: "item_price")(json)
        is_rated = Decoder.decode(key: "is_rated")(json)
        fromType = Decoder.decode(key: "from_type")(json)
        total_price = Decoder.decode(key: "total_price")(json)
        actual_paid = Decoder.decode(key: "actual_paid")(json)
        search_delegates_started_at = Decoder.decode(key: "search_delegates_started_at")(json)
        cancel_reason = Decoder.decode(decodableForKey: "cancel_reason")(json)
        delivery_duration = Decoder.decode(key: "delivery_duration")(json)
        discount = Decoder.decode(key: "discount")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "status")(self.status),
            Encoder.encode(key: "delegate")(self.delegate),
            Encoder.encode(key: "store_name")(self.store_name),
            Encoder.encode(key: "from_address")(self.from_address),
            Encoder.encode(key: "to_address")(self.to_address),
            Encoder.encode(key: "description")(self.desc),
            Encoder.encode(key: "images")(self.images),
            Encoder.encode(key: "from_lat")(self.from_lat),
            Encoder.encode(key: "from_lng")(self.from_lng),
            Encoder.encode(key: "to_lat")(self.to_lat),
            Encoder.encode(key: "to_lng")(self.to_lng),
            Encoder.encode(key: "finance_settings")(self.finance_settings),
            Encoder.encode(key: "offers")(self.offers),
            Encoder.encode(key: "created_by")(self.user),
            Encoder.encode(key: "search_delegates_result")(self.search_delegates_result),
            Encoder.encode(key: "delivery_price")(self.delivery_price),
            Encoder.encode(key: "vat")(self.vat),
            Encoder.encode(key: "commission")(self.commission),
            Encoder.encode(key: "item_price")(self.item_price),
            Encoder.encode(key: "is_rated")(self.is_rated),
            Encoder.encode(key: "from_type")(self.fromType),
            Encoder.encode(key: "total_price")(self.total_price),
            Encoder.encode(key: "actual_paid")(self.actual_paid),
            Encoder.encode(key: "search_delegates_started_at")(self.search_delegates_started_at),
            Encoder.encode(key: "cancel_reason")(self.cancel_reason),
            Encoder.encode(key: "delivery_duration")(self.delivery_duration),
            Encoder.encode(key: "discount")(self.discount),
            Encoder.encode(key: "created_at")(self.created_at)
            ])
    }
}
