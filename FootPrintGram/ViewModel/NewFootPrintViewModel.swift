//
//  NewFootPrintViewModel.swift
//  FootPrintGram
//
//  Created by 정하민 on 23/09/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class NewFootPrintViewModel {
    
    private let disposeBag = DisposeBag()
    
    public let titleConnector:BehaviorSubject<String>
    public let latitudeValue: BehaviorSubject<String>
    public let longitudeValue: BehaviorSubject<String>
    public let newAnnoValue:BehaviorSubject<FootPrintAnnotation?> = BehaviorSubject(value: nil)
    public let postData = BehaviorSubject(value: [])
    public let image = BehaviorSubject(value: #imageLiteral(resourceName: "AddImage"))
    
    public var scrollViewHeight:CGFloat = 100
    public let titleData: Driver<String>
    public let registerButtonEnabled: Driver<Bool>
    
    public let latitude: Driver<String>
    public let longitude: Driver<String>
    public let post: Observable<[String:String]>
    
    init(_ lat: String, _ long: String) {
        titleConnector = BehaviorSubject(value: "")
        
        titleData = titleConnector
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
        
        latitudeValue = BehaviorSubject(value: lat)
        
        latitude = latitudeValue
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
        
        longitudeValue = BehaviorSubject(value: long)
        
        longitude = longitudeValue
        .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
        
        post = Observable.combineLatest(titleConnector.asObservable(), latitudeValue.asObservable(), longitudeValue.asObservable(), resultSelector:{ a,b,c in
            return ["name": a, "latitude": b, "longitude": c, "created": Date().description]
        })
        
        let temp:Observable<Bool> = Observable.combineLatest(titleConnector.asObservable(), latitudeValue.asObservable(), longitudeValue.asObservable(), resultSelector:{ a,b,c in
            if a != "", b != "", c != "" {
                return true
            }
            return false
        })
        
        registerButtonEnabled = temp.asDriver(onErrorJustReturn: false)
        
        _ = image.distinctUntilChanged()
            .subscribe({ [weak self] image in
                guard let image = image.element else { return }
                self?.scrollViewHeight = image.size.height
            }).disposed(by: disposeBag)
        
    }
    
    public func makeUploadImage() -> Data? {
        var returnData: Data!
        do {
            try! returnData = image.value().jpegData(compressionQuality: 0.1)
        }
        catch {
            return nil
        }
        return returnData
    }
    
    public func makePostData2(url: String) -> Observable<[String:String]> {
        return post.asObservable().map { (postData) in
            return ["name": postData["name"]!, "latitude": postData["latitude"]!, "longitude": postData["longitude"]!, "created": postData["created"]!, "url": url]
        }
    }
    
    public func makePostData() ->[String:String] {
        return [String:String]()
    }

}
