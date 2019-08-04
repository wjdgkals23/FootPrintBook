//
//  FootPrint.swift
//  FootPrintGram
//
//  Created by 정하민 on 03/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation

class FootPrint: Codable {
    var title: String?
    var image: Data?
    var latitude = 0.0
    var longitude = 0.0
    var created = Date()
}
