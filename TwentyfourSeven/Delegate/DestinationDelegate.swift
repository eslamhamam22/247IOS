//
//  DestinationDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/24/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol DestinationDelegate {
    
    func selectAddress(latitude : Double, longitude: Double, address: String, title: String)
    
}
