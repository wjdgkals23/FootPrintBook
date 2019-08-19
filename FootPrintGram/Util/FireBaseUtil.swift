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
import MapKit
import PromiseKit


class FireBaseUtil {
    
    static let shared = FireBaseUtil()
    
    var userInfo = UserInfo.shared
    
    let settingMeta = StorageMetadata.init()
    let storage = Storage.storage().reference().child("userPostImage")
    
    var mainData: FootPrintAnnotationList!
    var ref = Database.database().reference()
    
    var lastData: NSDictionary!
    
    var recentStorage: StorageReference!
    
    func callAllPostWithLoadingUI() -> Promise<String> {
        return Promise<String> { [unowned self] scene -> Void in
            self.ref.child("footprintPosts").child(self.userInfo.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if(!snapshot.exists()) {
                    scene.fulfill("NotExist")
                }
                guard let value = (snapshot.value as? NSDictionary) else { return }
                
                if(value != self.lastData) {
                    self.lastData = value
                    FootPrintAnnotationList.shared.fpaList?.removeAll()
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let key = snap.key
                        let value = snap.value as! NSDictionary
                        print(key, value)
                        let cood = CLLocationCoordinate2D.init(latitude: Double(value["latitude"] as! String)! as CLLocationDegrees, longitude: Double(value["longitude"] as! String)! as CLLocationDegrees)
                        let title = value["name"] as? String
                        let imageUrl = value["profileImageURL"] as? String
                        let created = value["created"] as? String
                        let item = FootPrintAnnotation.init(coordinate: cood, title: title!, imageUrl: imageUrl!, created: created, id: key)
                        //                        item.id = key
                        FootPrintAnnotationList.shared.fpaList!.append(item)
                    }
                    self.mainData = FootPrintAnnotationList.shared
                    scene.fulfill("SUC")
                }
            }, withCancel: nil)
        }
    }
    
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
    
    private func callDeleteById(_ ind: Int, _ id: String) -> Promise<String> {
        return Promise<String> { scene -> Void in
            let deleteStorage = Storage.storage().reference(forURL: self.mainData.fpaList![ind].post.imageUrl!)
            deleteStorage.delete(completion: { (err) in
                guard let err = err else { return scene.fulfill("SUC") }
                return scene.reject(err)
            })
        }
    }
    
    private func callDeleteDBById(_ id: String) -> Promise<String> {
        return Promise<String> { scene in self.ref.child("footprintPosts").child(self.userInfo.uid).child(id).removeValue(completionBlock: { (err, ref) in
                guard let err = err else { return scene.fulfill("SUC") }
                return scene.reject(err)
            })
        }
    }
    
    func totalFunc(_ title: String, _ data: Data, data2: [String:String]) -> Promise<String> {
        return callPhotoPut(title, data).then {
                _ in self.callPhotoDownUrl()
            }.then {
                url in self.callPostUpdateWithLoadingUI(data: data2, url: url)
            }
    }
    
    func deleteTotalFunc(_ ind: Int,_ id: String) -> Promise<String> {
        return callDeleteById(ind, id).then{
            _ in self.callDeleteDBById(id)
        }
    }
    
    enum tempError: Error { // 전역화
        case one
        case two
        case three
    }
    
}

