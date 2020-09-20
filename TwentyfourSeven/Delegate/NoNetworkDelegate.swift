//
//  NoNetworkDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 4/4/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol NoNetworkDelegate : class{
    
    func setAboutUsData(data: PagesData)
    func setContactUsData(data: ContactUsData)
    func setCarDetailsData(data: CarDetailsData)
    
}
