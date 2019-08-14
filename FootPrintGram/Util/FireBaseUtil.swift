//
//  FireBaseUtil.swift
//  FootPrintGram
//
//  Created by 정하민 on 14/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class FireBaseUtil {
    
    static let shared = FireBaseUtil()
    
    var userInfo = UserInfo.shared
    
    func callPostUpdateWithLoadingUI(data: [String:String], completion: @escaping (_ error: NSError?, _ ref: DatabaseReference) -> Void) {
        let r_data = (data as NSDictionary)
        Database.database().reference().child("footprintPosts").child(self.userInfo.uid).childByAutoId().setValue(r_data, withCompletionBlock: { (err, ref) in
            completion(err as NSError?, ref)
        })
    }
}

