//
//  NewFootPrintViewModel.swift
//  FootPrintGram
//
//  Created by 정하민 on 23/09/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import RxSwift
import MapKit

class NewFootPrintViewModel {
    
    let disposeBag = DisposeBag()
    let titleText = BehaviorSubject(value: "")
   
    let latitudeValue = BehaviorSubject(value: "")
    let longitudeValue = BehaviorSubject(value: "")
    
    let newAnnoValue:BehaviorSubject<FootPrintAnnotation?> = BehaviorSubject(value: nil)
    
    let postData = BehaviorSubject(value: [])
    
    let image = BehaviorSubject(value: #imageLiteral(resourceName: "AddImage"))
    
    private var scrollViewHeight:CGFloat = 100
    private var titleData = ""
    private var latitude = ""
    private var longitude = ""
    
    
    init() {
        _ = image.distinctUntilChanged()
            .subscribe({ [weak self] image in
                guard let image = image.element else { return }
                self?.scrollViewHeight = image.size.height
            }).disposed(by: disposeBag)
        
        _ = titleText.distinctUntilChanged()
            .subscribe({ [weak self] title in
                guard let title = title.element else { return }
                self?.titleData = title
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
    
    public func makeTitle() -> String? {
        return titleData
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
    
    public func makePostData() -> [String:String] {
        return ["name": self.titleData, "latitude": self.latitude, "longitude": self.longitude, "created": Date().description]
    }

}
