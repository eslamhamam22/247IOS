//
//  PinAnnotation.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import MapKit

class PinAnnotation : NSObject, MKAnnotation
{
    var title:String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String , subtitle: String , coordinate : CLLocationCoordinate2D) {
        self.title=title
        self.subtitle=subtitle
        self.coordinate=coordinate
    }
}
