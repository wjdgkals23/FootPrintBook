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
    var post: Post
    
    var title: String? {
        return post.title
    }
    var subtitle: String? {
        return nil
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String, imageUrl: String?) {
        self.coordinate = coordinate
        if let imageString = imageUrl {
            self.post = Post.init(title: title, imageUrl: imageString, created: Date.init().description)
        } else {
            self.post = Post.init(title: title, imageUrl: "@default", created: Date.init().description)
        }
    }
}
