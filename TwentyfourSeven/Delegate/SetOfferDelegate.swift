//
//  SetOfferDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/18/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol SetOfferDelegate {
    
    func setOfferSuccessfully(shippingCost: Double, Commission: Double, VAT: Double, totalRecieve: Double)
    
}
