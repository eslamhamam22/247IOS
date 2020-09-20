//
//  ImageDelegate.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/10/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol ImageDelegate : class{
    
    func showImage(url: String)
    func saveImagetoDB(chatImage : ChatImage)
    
}
