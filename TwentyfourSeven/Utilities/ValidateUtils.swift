//
//  ValidateUtils.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/20/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class ValidateUtil {
    
    static func isValidName(_ input:String) -> Bool {
        let stringRegex = "^[a-zA-Z0-9\\s\\u0600-\\u06ff\\u0750-\\u077f\\ufb50-\\ufc3f\\ufe70-\\ufefc]*";
        return NSPredicate(format: "SELF MATCHES %@", stringRegex).evaluate(with: input)
        
    }
    
    
}
