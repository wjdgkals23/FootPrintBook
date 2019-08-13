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
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageUrl: String?
    var created: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, imageUrl: String?) {
        self.coordinate = coordinate
        self.title = title
        self.imageUrl = imageUrl
        self.created = Date.init().description
    }
}
