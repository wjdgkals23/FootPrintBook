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
    
    var fpaList: [FootPrintAnnotation]?
    
    init() {
        fpaList = [FootPrintAnnotation]()
    }

}
