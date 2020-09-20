

//
//  AddressesRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit


protocol AddressesRepository {
    
    func getAddresses(completionHandler: @escaping (_ resultData : MyAddressesResponse?, _ error : NetworkAddressesRepository.ErrorType) -> ())

    func deleteAddress(id: Int, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkAddressesRepository.ErrorType) -> ())
    
    func addAddress(title: String,address: String, lat: Double, lng: Double, completionHandler: @escaping (_ resultData : BasicResponse?, _ error : NetworkAddressesRepository.ErrorType) -> ())

}
