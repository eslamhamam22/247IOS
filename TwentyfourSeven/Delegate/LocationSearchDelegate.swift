//
//  LocationSearchDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/2/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol LocationSearchDelegate {
    func addSearchAddress(latitude : Double, longitude : Double, address : String)
}
