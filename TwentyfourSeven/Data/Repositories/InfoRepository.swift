//
//  InfoRepository.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/18/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit


protocol InfoRepository {
    
    func getPages(slug : String, completionHandler: @escaping (_ resultData : PagesResponse?, _ error : NetworkInfoRepository.ErrorType) -> ())
    
    func getContactUs(completionHandler: @escaping (_ resultData : ContactUsResponse?, _ error : NetworkInfoRepository.ErrorType) -> ())

    func getHowToUse(completionHandler: @escaping (_ resultData : HowToUseResponse?, _ error : NetworkInfoRepository.ErrorType) -> ())

    func getHowToBecomeDelegate(completionHandler: @escaping (_ resultData : HowToUseResponse?, _ error : NetworkInfoRepository.ErrorType) -> ())

    func getPrayerTimes(completionHandler: @escaping (_ resultData : PrayerTimesResponse?, _ error : NetworkInfoRepository.ErrorType) -> ())

}
