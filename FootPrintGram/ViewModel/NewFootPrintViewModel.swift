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
    public let latitudeValue = BehaviorSubject(value: "")
    public let longitudeValue = BehaviorSubject(value: "")
    public let newAnnoValue:BehaviorSubject<FootPrintAnnotation?> = BehaviorSubject(value: nil)
    public let postData = BehaviorSubject(value: [])
    public let image = BehaviorSubject(value: #imageLiteral(resourceName: "AddImage"))
    
    public var scrollViewHeight:CGFloat = 100
    public let titleData: Driver<String>
    public let registerButtonEnabled: Driver<Bool>
    
    public var latitude = ""
    public var longitude = ""
    public let post: Observable<[String:String]>
    
    init() {
        titleConnector = BehaviorSubject(value: "")
        
        titleData = titleConnector
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
        
        _ = latitudeValue.distinctUntilChanged()
            .subscribe({ [weak self] latitude in
                self?.latitude = latitude.element!
            }).disposed(by: disposeBag)
        
        _ = longitudeValue.distinctUntilChanged()
            .subscribe({ [weak self] longitude in
                self?.longitude = longitude.element!
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
        return Observable.combineLatest(titleConnector.asObservable(), latitudeValue.asObservable(), longitudeValue.asObservable(), resultSelector:{ a,b,c in
            return ["name": a, "latitude": b, "longitude": c, "created": Date().description, "url": url]
        })
    }
    
    public func makePostData() ->[String:String] {
        return [String:String]()
    }

}
