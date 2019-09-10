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
import RxSwift

class FireBaseUtil {
    
    static let shared = FireBaseUtil()
    
    private var userInfo = UserInfo.shared
    
    private let settingMeta = StorageMetadata.init()
    private let storage = Storage.storage().reference().child("userPostImage")
    
    private var ref = Database.database().reference();
    
    var recentStorage: StorageReference!
    
    private func callDeleteById(_ ind: Int, _ id: String) -> Promise<String> {
        return Promise<String> { scene -> Void in

            guard let imgUrl = FootPrintAnnotationList.shared.itemImageUrl(ind: ind) else { return }
            let deleteStorage = Storage.storage().reference(forURL: imgUrl)
            deleteStorage.delete(completion: { (err) in
                guard let errorCode = (err as NSError?)?.code else { return scene.fulfill("SUC") }
                guard let error = StorageErrorCode(rawValue: errorCode) else { return }
                switch error {
                case .objectNotFound:
                    print("Not Found");
                    return scene.fulfill("SUC")
                @unknown default:
                    print("Not")
                    return scene.reject(errorCode as! Error)
                }
            })
        }
    }
    
    private func callDeleteDBById(_ id: String) -> Promise<String> {
        return Promise<String> { scene in self.ref.child("footprintPosts").child(self.userInfo.o_uid).child(id).removeValue(completionBlock: { (err, ref) in
                guard let err = err else { return scene.fulfill("SUC") }
                return scene.reject(err)
            })
        }
    }
    
    func deleteTotalFunc(_ ind: Int,_ id: String) -> Promise<String> {
        return callDeleteById(ind, id).then{
            _ in self.callDeleteDBById(id)
        }
    }
    
    enum tempError: Error { // 전역화
        case NotExist
        case CastingError
        case UnwrappedError
    }
    
}

extension FireBaseUtil {
    
    func fbAllPostLoad(completed: @escaping (DataSnapshot?) -> Void, cancel: ((Error) -> Void)?) {
        DispatchQueue.global().async {
            self.ref.child("footprintPosts").child(self.userInfo.o_uid).observeSingleEvent(of: .value, with: completed, withCancel: cancel)
        }
    }
    
    func rxAllPostLoad() -> Observable<String> {
        return Observable.create { seal in
            self.fbAllPostLoad(completed: { (snapshot) in
                guard let snapshot = snapshot else { return seal.onError(tempError.UnwrappedError) }
                
                if(!snapshot.exists()) {
                    seal.onError(tempError.NotExist)
                }
                FootPrintAnnotationList.shared.removeAllItem()
                
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
                    FootPrintAnnotationList.shared.appendItem(item: item)
                }
                seal.onNext("SUC")
            }, cancel: nil)
            return Disposables.create()
        }
    }
    
    func fbUploadData(data: [String:String], url: String, completed: @escaping (Error?, DatabaseReference?) -> Void) {
        var temp_data = data
        temp_data["profileImageURL"] = url
        let r_data = (temp_data as NSDictionary)
        DispatchQueue.global().async {
            Database.database().reference().child("footprintPosts").child(self.userInfo.o_uid).childByAutoId().setValue(r_data, withCompletionBlock: completed)
        }
    }

    func rxUploadData(data: [String:String], url: String) -> Observable<Bool?> {
        return Observable.create { seal in
            self.fbUploadData(data: data, url: url) { (err, ref) in
                guard let ref = ref else { return seal.onError(err!) }
                seal.onNext(true)
                seal.onCompleted()
            }
            return Disposables.create()
        }
    }

    func fbUploadImage(_ title: String, _ data: Data, completed: @escaping (StorageMetadata?, Error?) -> Void) {
        settingMeta.contentType = "image/jepg"
        let r_storage = storage.child(userInfo.o_uid).child(title + Date.init().description)
        recentStorage = r_storage
        
        DispatchQueue.global().async {
            r_storage.putData(data, metadata: self.settingMeta, completion: completed)
        }
    }

    func rxUploadImage(_ title: String, _ data: Data) -> Observable<Bool?> {
        return Observable.create { seal in
            self.fbUploadImage(title, data) { smeta, err in
                guard let smeta = smeta else { return seal.onError(err!) }
                seal.onNext(true)
            }
            return Disposables.create()
        }
    }

    func fbGetImageUrl(completed: @escaping (URL?, Error?) -> Void) {
        guard let rStorage = recentStorage else { return }
        DispatchQueue.global().async {
            rStorage.downloadURL(completion: completed)
        }
    }

    func rxGetImageUrl() -> Observable<String?> {
        return Observable.create { seal in
            self.fbGetImageUrl(){ url, err in
                guard let url = url else { return seal.onError(err!) }
                seal.onNext(url.absoluteString)
            }
            return Disposables.create()
        }
    }
    
}

