//
//  BankAccount.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class BankAccount: NSObject, Glossy{
    
    var id : Int?
    var account_number : String?
    var bank_name : String?
    var branch_name : String?

    override init() {
        id = 0
        account_number = ""
        bank_name = ""
        branch_name = ""

    }
    
    init(  id : Int?, account_number : String? , bank_name : String? , branch_name : String?) {
        self.id = id
        self.account_number = account_number
        self.bank_name = bank_name
        self.branch_name = branch_name

    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        account_number = Decoder.decode(key: "account_number")(json)
        bank_name = Decoder.decode(key: "bank_name")(json)
        branch_name = Decoder.decode(key: "branch_name")(json)

    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "account_number")(self.account_number),
            Encoder.encode(key: "bank_name")(self.bank_name),
            Encoder.encode(key: "branch_name")(self.branch_name)
            ])
    }
}
