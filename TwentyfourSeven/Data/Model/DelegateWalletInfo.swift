//
//  DelegateWalletInfo.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class DelegateWalletInfo: NSObject, Glossy{
    
    var balance : String?
    var earnings : Double?

    override init() {
        balance = ""
        earnings = 0.0
       
    }
    
    init( balance : String? , earnings : Double?) {
        self.balance = balance
        self.earnings = earnings
    }
    
    required init?(json : JSON){
        balance = Decoder.decode(key: "balance")(json)
        earnings = Decoder.decode(key: "earnings")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "balance")(self.balance),
            Encoder.encode(key: "earnings")(self.earnings)
            ])
    }
}
