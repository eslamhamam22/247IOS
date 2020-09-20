//
//  ChatMessage.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

class ChatMessage : NSObject{
    
    var msg : Message?
    var images : [ChatImage]?
    var created_by : Int?
    var recipient_type : ChatRecipientType?
    var created_at :Double?
    
    override init() {
       msg = Message()
       images = [ChatImage]()
    }
    
    init( msg : Message? , images : [ChatImage]? , created_by : Int? , recipient_type : ChatRecipientType? , created_at :Double?) {
        self.msg = msg
        self.images = images
        self.created_by = created_by
        self.recipient_type = recipient_type
        self.created_at = created_at
    }
    
}

enum ChatRecipientType : Int{
    case  RECIPIENT_TYPE_CUSTOMER = 0
    case  RECIPIENT_TYPE_DELEGATE = 1
    case  RECIPIENT_TYPE_ALL      = 2
}
