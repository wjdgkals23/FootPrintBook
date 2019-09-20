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
        
        guard let title = title else {
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm"
            let result = dateFormatter.string(from: Date())
            self.id = nil
            self.post = Post.init(title: "Add New Post", imageUrl: nil, created: result)
            return
        }
        
        self.id = id!;
        self.post = Post.init(title: title, imageUrl: imageUrl!, created: created!)
    }
}
