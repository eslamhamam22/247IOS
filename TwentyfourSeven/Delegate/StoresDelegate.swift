//
//  StoresDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/15/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol StoresDelegate {
    
    func selectedHeader(isNearBy : Bool)
    func selectedStore(store : Place)
    func updateStore(store : Place, index: Int, isNearby: Bool)

}
