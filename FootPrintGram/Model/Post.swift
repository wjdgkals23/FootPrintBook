//
//  Post.swift
//  FootPrintGram
//
//  Created by 정하민 on 14/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation

class Post {
    var title: String?
    var imageUrl: String?
    var created: String?
    
    init(title: String, imageUrl: String, created: String) {
        self.title = title
        self.imageUrl = imageUrl
        self.created = created
    }
    
}
