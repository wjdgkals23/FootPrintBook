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
    var id: String?
    
    var title: String? {
        return post.title
    }
    var subtitle: String? {
        return post.created?.description
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String?, imageUrl: String?, created: String?, id: String?) {
        self.coordinate = coordinate
        self.id = id
        if let title = title, let imageString = imageUrl, let createdString = created {
            self.post = Post.init(title: title, imageUrl: imageString, created: createdString)
        } else {
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm"
            let result = dateFormatter.string(from: Date())
            self.post = Post.init(title: nil, imageUrl: nil, created: result)
        }
    }
}
