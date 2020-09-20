//
//  RequestFromStoreDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation

protocol RequestFromStoreDelegate {
    
    func playRecord()
    
    func pauseRecord()

    func deleteRecord()

    func deleteImage(id: Int)
}
