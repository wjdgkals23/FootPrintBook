//
//  FootPrintAnnotationList.swift
//  FootPrintGram
//
//  Created by 정하민 on 12/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation

class FootPrintAnnotationList {
    
    static let shared = FootPrintAnnotationList()
    
    private var fpaList: [FootPrintAnnotation]?
    
    public func itemImageUrl(ind: Int) -> String? {
        return fpaList![ind].post.imageUrl
    }
    
    public func removeAllItem() {
        fpaList?.removeAll()
    }
    
    public func appendItem(item: FootPrintAnnotation) {
        fpaList?.append(item)
    }
    
    public func getList() -> [FootPrintAnnotation]? {
        return self.fpaList
    }
    
    init() {
        fpaList = [FootPrintAnnotation]()
    }

}
