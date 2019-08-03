//
//  FootPrintAnnotation.swift
//  FootPrintGram
//
//  Created by 정하민 on 03/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import MapKit

class FootPrintAnnotation: NSObject, MKAnnotation {
    var footprint: FootPrint?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, footprint: FootPrint? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.footprint = footprint
    }
}
