//
//  Transaction.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class Transaction: NSObject, Glossy{
    
    var id : Int?
    var amount : Double?
    var transaction_desc : String?
    var payment_method: Int?
    var transaction_type: Int?
    var related_order : Order?
    var created_at : String?
    var paymentTitle : String?

    override init() {
         id = 0
         amount = 0.0
         transaction_desc = ""
         payment_method = 0
         transaction_type = 0
         related_order = Order()
         created_at = ""
         paymentTitle = ""
    }
    
    init(  id : Int? , amount : Double? , transaction_desc : String? , payment_method: Int?
    ,  transaction_type: Int? , related_order : Order? , created_at : String? , paymentTitle : String?) {
        self.id = id
        self.amount = amount
        self.transaction_desc = transaction_desc
        self.payment_method = payment_method
        self.transaction_type = transaction_type
        self.related_order = related_order
        self.created_at = created_at
        self.paymentTitle = paymentTitle

    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        amount = Decoder.decode(key: "amount")(json)
        transaction_desc = Decoder.decode(key: "description")(json)
        payment_method = Decoder.decode(key: "payment_method")(json)
        transaction_type = Decoder.decode(key: "transaction_type")(json)
        related_order = Decoder.decode(decodableForKey: "related_order")(json)
        created_at = Decoder.decode(key: "created_at")(json)
        paymentTitle = Decoder.decode(key: "title")(json)

    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "amount")(self.amount),
            Encoder.encode(key: "transaction_desc")(self.transaction_desc),
            Encoder.encode(key: "payment_method")(self.payment_method),
            Encoder.encode(key: "transaction_type")(self.transaction_type),
            Encoder.encode(key: "related_order")(self.related_order),
            Encoder.encode(key: "created_at")(self.created_at),
            Encoder.encode(key: "title")(self.paymentTitle)

            ])
    }
}
