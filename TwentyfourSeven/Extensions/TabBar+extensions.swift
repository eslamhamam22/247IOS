//
//  TabBar+extensions.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/17/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136 , 1334 , 1920, 2208:
                sizeThatFits.height = 60
            default:
                sizeThatFits.height = 100
            }
        }
        return sizeThatFits
    }
}
