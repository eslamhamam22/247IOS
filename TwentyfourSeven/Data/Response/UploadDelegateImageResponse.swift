//
//  UploadDelegateImageResponse.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class UploadDelegateImageResponse : Gloss.Decodable {
    
    var status : Bool? = false
    var error : ErrorData?
    var data : DelegateImageData?
    
    init() {
        status = false
        data =  DelegateImageData()
        error = ErrorData()
    }
    
    required init?(json: JSON) {
        self.status = Decoder.decode(key: "status")(json)
        self.data = Decoder.decode(decodableForKey: "data")(json)
        self.error = Decoder.decode(decodableForKey: "error")(json)
    }
    
}
