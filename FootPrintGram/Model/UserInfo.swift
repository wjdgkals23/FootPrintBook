//
//  UserInfo.swift
//  FootPrintGram
//
//  Created by 정하민 on 07/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation

class UserInfo {
    private var uid: String!
    private var email: String!
    
    var o_uid: String! {
        get {
            return uid
        }
        set(new) {
            self.uid = new
        }
    }
    
    var o_email: String! {
        get {
            return self.email
        }
        set(new) {
            self.email = new
        }
    }
    
    static let shared = UserInfo()
}
