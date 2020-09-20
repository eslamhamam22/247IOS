//
//  FinanceSettings.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/17/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class FinanceSettings: NSObject, Glossy{
    
    var vat_type : String?
    var vat_value : String?
    var commission_type : String?
    var commission_value : String?
    var min_mileage_cost : String?
    var max_mileage_cost : String?
    var min_fixed_cost : String?

    override init() {
        vat_type = ""
        vat_value = ""
         commission_type = ""
         commission_value = ""
         min_mileage_cost = ""
         max_mileage_cost = ""
         min_fixed_cost = ""
    }
    
    init(vat_type : String?, vat_value : String?, commission_type : String?, commission_value : String?, min_mileage_cost : String?, max_mileage_cost : String?, min_fixed_cost : String?) {
        
        self.vat_type = vat_type
        self.vat_value = vat_value
        self.commission_type = commission_type
        self.commission_value = commission_value
        self.min_mileage_cost = min_mileage_cost
        self.max_mileage_cost = max_mileage_cost
        self.min_fixed_cost = min_fixed_cost
    }
    
    required init?(json : JSON){
        vat_type = Decoder.decode(key: "vat_type")(json)
        vat_value = Decoder.decode(key: "vat_value")(json)
        commission_type = Decoder.decode(key: "commission_type")(json)
        commission_value = Decoder.decode(key: "commission_value")(json)
        min_mileage_cost = Decoder.decode(key: "min_mileage_cost")(json)
        max_mileage_cost = Decoder.decode(key: "max_mileage_cost")(json)
        min_fixed_cost = Decoder.decode(key: "min_fixed_cost")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "vat_type")(self.vat_type),
            Encoder.encode(key: "vat_value")(self.vat_value),
            Encoder.encode(key: "commission_type")(self.commission_type),
            Encoder.encode(key: "commission_value")(self.commission_value),
            Encoder.encode(key: "min_mileage_cost")(self.min_mileage_cost),
            Encoder.encode(key: "max_mileage_cost")(self.max_mileage_cost),
            Encoder.encode(key: "min_fixed_cost")(self.min_fixed_cost)
            ])
    }
}
