//
//  CALayer+extensions.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/11/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
    
    func setCornerRadious(radious : CGFloat, maskToBounds : Bool){
        self.cornerRadius = radious
        self.masksToBounds = maskToBounds
    }
    
    func setShadow(opacity : Float , radious : CGFloat , shadowColor : CGColor){
        self.shadowColor = shadowColor
        self.shadowOpacity = opacity
        self.shadowOffset = CGSize.zero
        self.shadowRadius = radious
    }
    
    
    func setBorder(borderColor : CGColor ,  width : CGFloat ){
        self.borderColor = borderColor
        self.borderWidth = width
    }
    
    func makeBorderWithCornerRadius(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let rect = self.bounds;
        
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the shape layer and set its path
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path  = maskPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        self.mask = maskLayer
        
        //Create path for border
        let borderPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the shape layer and set its path
        let borderLayer = CAShapeLayer()
        
        borderLayer.frame       = rect
        borderLayer.path        = borderPath.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor   = UIColor.clear.cgColor
        borderLayer.lineWidth   = borderWidth * UIScreen.main.scale
        borderLayer.masksToBounds = true
        //Add this layer to give border.
        self.addSublayer(borderLayer)
    }
}
