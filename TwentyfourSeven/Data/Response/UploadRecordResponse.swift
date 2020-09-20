//
//  UploadRecordResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class UploadRecordResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : AudioRecorderData?
    
    init() {
        status = false
        data = AudioRecorderData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
