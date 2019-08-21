//
//  DevideSimulReal.swift
//  FootPrintGram
//
//  Created by 정하민 on 21/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if SIMULATOR
            isSim = true
        #endif
        return isSim
    }()
}
