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
import PromiseKit

class FireBaseUtil {
    
    static let shared = FireBaseUtil()
    
    var userInfo = UserInfo.shared
    
    let settingMeta = StorageMetadata.init()
    let storage = Storage.storage().reference().child("userPostImage")
    
    var recentStorage: StorageReference!
    
    private func callPostUpdateWithLoadingUI(data: [String:String], url: String) -> Promise<String> {
        var temp_data = data
        temp_data["profileImageURL"] = url
        let r_data = (temp_data as NSDictionary)
        return Promise<String> { scene -> Void in        Database.database().reference().child("footprintPosts").child(self.userInfo.uid).childByAutoId().setValue(r_data, withCompletionBlock: { (err, ref) in
                guard let error = err else { return scene.fulfill("SUC") }
                return scene.reject(error)
            })
        }
    }
    
    private func callPhotoPut(_ title: String, _ data: Data) -> Promise<String> {
        settingMeta.contentType = "image/jepg"
        let r_storage = storage.child(userInfo.uid).child(title + Date.init().description)
        recentStorage = r_storage
        return Promise<String> { scene -> Void in
            r_storage.putData(data, metadata: settingMeta, completion: { (ref, err) in
                guard let err = err else { return scene.fulfill("SUC") }
                return scene.reject(err)
            })
        }
    }
    
    private func callPhotoDownUrl() -> Promise<String> {
        return Promise<String> { scene -> Void in
            guard let rStorage = recentStorage else { return scene.reject(tempError.one) }
            rStorage.downloadURL(completion: { (url, err) in
                guard let err = err else { return scene.fulfill(url!.absoluteString) }
                return scene.reject(err)
            })
        }
    }
    
    func totalFunc(_ title: String, _ data: Data, data2: [String:String]) -> Promise<String> {
        return
            callPhotoPut(title, data)
            .then {
                _ in
                self.callPhotoDownUrl()
            }.then {
                url in
                self.callPostUpdateWithLoadingUI(data: data2, url: url)
            }
        
    }
    
    enum tempError: Error { // 전역화
        case one
        case two
        case three
    }
    
}

