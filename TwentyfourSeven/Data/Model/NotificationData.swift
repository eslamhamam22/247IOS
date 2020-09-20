//
//  NotificationData.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/4/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import Gloss

class NotificationData: NSObject, Glossy{
    
    var notifications : [Notification]?
    var unseen_count : Int?
   
    override init() {
       notifications = [Notification]()
    }
    
    init( notifications : [Notification]? , unseen_count : Int?) {
        self.notifications = notifications
        self.unseen_count = unseen_count
    }
    
    required init?(json : JSON){
        unseen_count = Decoder.decode(key: "unseen_count")(json)
        notifications = Decoder.decode(decodableArrayForKey: "notifications")(json)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            Encoder.encode(key: "unseen_count")(self.unseen_count),
            Encoder.encode(key: "notifications")(self.notifications)
            ])
    }
}
