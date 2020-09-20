//
//  AddressesDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/31/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation

protocol AddressesDelegate {
    
    func deleteAddress(id : Int)
    func addAddressSuccessfully()
    func selectAddress(address : Address)
}
