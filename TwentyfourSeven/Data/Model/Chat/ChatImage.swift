//
//  ChatImage.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

class ChatImage : NSObject{
    
    var id : Int?
    var url : String?
    
    override init() {
       id = 0
       url = ""
    }
    
    init( id : Int? , url : String?) {
        self.id = id
        self.url = url 
    }
    

}
