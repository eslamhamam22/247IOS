//
//  AcceptOfferDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol AcceptOfferDelegate {
    
    func acceptOffer(offerID: Int, offerPrice: String)
    
    func rejectOffer(offerID: Int, offerPrice: String)
    
    func delegateProfilePressed(delegateId: Int)
}
