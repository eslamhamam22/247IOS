//
//  AudioRecorderData.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class AudioRecorderData: NSObject, Glossy{
    
    var id : Int?
    var voicenote : String?
    
    override init() {
        id = 0
        voicenote = ""
    }
    
    init( id : Int? , voicenote : String?) {
        self.id = id
        self.voicenote = voicenote
    }
    
    required init?(json : JSON){
        id = Decoder.decode(key: "id")(json)
        voicenote = Decoder.decode(key: "voicenote")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "id")(self.id),
            Encoder.encode(key: "voicenote")(self.voicenote)
            ])
    }
}
