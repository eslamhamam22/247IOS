//
//  PrayerTimes.swift
//  TwentyfourSeven
//
//  Created by Salma  on 5/19/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class PrayerTimes: NSObject, Glossy{
    
    var Asr : String?
    var Dhuhr: String?
    var Fajr: String?
    var Isha: String?
    var Maghrib: String?

    override init() {
        Asr = ""
        Dhuhr = ""
        Fajr = ""
        Isha = ""
        Maghrib = ""
    }
    
    init(Asr : String?, Dhuhr: String?, Fajr: String?, Isha: String?, Maghrib: String?) {
        self.Asr = Asr
        self.Dhuhr = Dhuhr
        self.Fajr = Fajr
        self.Isha = Isha
        self.Maghrib = Maghrib
    }
    
    required init?(json : JSON){
        Asr = Decoder.decode(key: "Asr")(json)
        Dhuhr = Decoder.decode(key: "Dhuhr")(json)
        Fajr = Decoder.decode(key: "Fajr")(json)
        Isha = Decoder.decode(key: "Isha")(json)
        Maghrib = Decoder.decode(key: "Maghrib")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "Asr")(self.Asr),
            Encoder.encode(key: "Dhuhr")(self.Dhuhr),
            Encoder.encode(key: "Fajr")(self.Fajr),
            Encoder.encode(key: "Isha")(self.Isha),
            Encoder.encode(key: "Maghrib")(self.Maghrib)
            ])
    }
}
