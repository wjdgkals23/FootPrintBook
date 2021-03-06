//
//  ViewController.swift
//  FootPrintGram
//
//  Created by 정하민 on 03/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD
import RxSwift
import RxMKMapView

class MapViewController: UIViewController {
    
    var mapView: MKMapView! = MKMapView()
    
    var lastAnnotation: FootPrintAnnotation!
    var selectedAnnotation: FootPrintAnnotation!
    
    let regionInMeters: CLLocationDistance = 250
    
    var locationManager = CLLocationManager()
    var userLocated = false
    
    var userInfo = UserInfo.shared
    var mainData: FootPrintAnnotationList!
    var ref = Database.database().reference()
    
    var selectedSign: String?
    
    weak var alertManager = MakeAlert.shared
    
    var disposeBag = DisposeBag()
    var annotationImageDict: [String:UIImage] = [String:UIImage]()
    
    let imageCache = NSCache<AnyObject, UIImage>()
    
    
    // MARK: - Override Func
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        setupView()
        checkLocationAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAnnotation2()
        
        guard let willAnnotation = selectedAnnotation else { return }

        let region = MKCoordinateRegion.init(center: willAnnotation.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewFootPrint" {
            let destination = segue.destination as! NewFootPrintViewController
            let senderAnnotation = sender as! FootPrintAnnotation
            destination.newAnnotation = senderAnnotation
        }
    }
    
    // MARK: - Private Func
    private func setupView() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { (make) in
            make.right.top.left.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        let removeButton = UIImageView.init(image: #imageLiteral(resourceName: "RemoveBtn"))
        removeButton.isUserInteractionEnabled = true
        let mapTap = UITapGestureRecognizer.init(target: self, action: #selector(modifyPin))
        removeButton.addGestureRecognizer(mapTap)
        
        let addButton = UIImageView.init(image: #imageLiteral(resourceName: "AddBtn"))
        addButton.isUserInteractionEnabled = true
        let addPinTap = UITapGestureRecognizer.init(target: self, action: #selector(addPin))
        addButton.addGestureRecognizer(addPinTap)
        
        let slideUp = UIImageView.init(image: #imageLiteral(resourceName: "SlideUpBtn"))
        slideUp.isUserInteractionEnabled = true
        let slideUpAction = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeUp))
        slideUpAction.direction = .up
        slideUp.addGestureRecognizer(slideUpAction)
        
        mapView.addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(mapView).offset(-10)
            make.width.height.equalTo(50)
        }
        
        mapView.addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(mapView).offset(-10)
            make.right.equalTo(removeButton).offset(-(removeButton.frame.size.width/2))
            make.width.height.equalTo(50)
        }
        
        mapView.addSubview(slideUp)
        slideUp.snp.makeConstraints { (make) in
            make.bottom.equalTo(mapView).offset(-20)
            make.centerX.equalTo(mapView)
            make.width.height.equalTo(50)
        }
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            centerToUsersLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            centerToUsersLocation()
        @unknown default:
            print("Error")
        }
    }
    
    private func getAnnotation2() {
        SVProgressHUD.show()
        FireBaseUtil.shared.rxAllPostLoad2()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { AnnotationList in
                self.mapView.removeAnnotations(self.mapView.annotations)
                SVProgressHUD.dismiss()
            })
            .drive(mapView.rx.annotations)
            .disposed(by: disposeBag)
    }
    
    private func loadImage2(_ item: FootPrintAnnotation) -> UIImage? { //cache
        let url = URL.init(string: item.post.imageUrl!)
        var image: UIImage!
        guard let data = NSData.init(contentsOf: url!) else {
            image = #imageLiteral(resourceName: "AddImage")
            imageCache.setObject(image, forKey: url as AnyObject)
            self.annotationImageDict[item.post.title!] = image
            return image
        }
        image = UIImage(data: data as Data)
        self.annotationImageDict[item.post.title!] = image
        return image
    }
    
    // MARK: - Gesture Func
    
    @objc func swipeUp(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .up {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "AnnotationTableViewController") as! AnnotationTableViewController
                self.navigationController?.pushViewController(view, animated: true)
            }
        }
    }
    
    @objc func addPin() {
        if lastAnnotation != nil {
            alertManager?.makeOneActionAlert(target: self, title: "Annotation already dropped", message: "There is an annotation on screen. Tap the Map If you want Remove Annotation", dismiss: true)
        } else {
            lastAnnotation = FootPrintAnnotation.init(coordinate: locationManager.location!.coordinate, title: nil, imageUrl: nil, created: nil, id: nil)
            self.mapView.addAnnotation(lastAnnotation)
            centerToUsersLocation()
        }
    }
    
    @objc func modifyPin() {
        if lastAnnotation != nil {
            mapView.removeAnnotation(lastAnnotation)
            lastAnnotation = nil
        } else {
            alertManager?.makeOneActionAlert(target: self, title: "Annotation already removed", message: "There is no a new annotation on screen.", dismiss: true)
        }
    }
    
    func centerToUsersLocation() {
        let center = mapView.userLocation.coordinate
        let zoomRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // MARK: - Action Func
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {
        if segue.identifier == "cancel" {
            print("cancel")
        } else if segue.identifier == "registerEnd" {
            mapView.removeAnnotation(lastAnnotation)
            mapView.removeAnnotations(mapView.annotations)
            lastAnnotation = nil
            getAnnotation2()
        }
    }
}

// MARK: - Delegate Func

extension MapViewController: MKMapViewDelegate {
    
    private func makePhotoView(anno: FootPrintAnnotation) -> UIView {
        let target = self.loadImage2(anno)!
        let ratio = target.size.height/target.size.width
        let height = (self.view.frame.width/3)*ratio
        let resizedImage = UIImage.resize(image: target, targetSize: CGSize.init(width: self.view.frame.width/3, height: height))
        
        let initView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width/3 + 30, height: height + 30))
        let label = UILabel.init()
        let text = NSMutableAttributedString.init(string: anno.post.created!)
        let font = UIFont.boldSystemFont(ofSize: 15)
        text.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: font, range: (anno.post.created! as NSString).range(of: anno.post.created!))
        label.attributedText = text
        initView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(initView)
            make.height.equalTo(20)
        }
        let imageView = UIImageView.init(image: resizedImage)
        initView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(label.snp.top)
            make.left.right.top.equalTo(initView)
        }
        return initView
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let currentAnnotation = annotation as? FootPrintAnnotation else { return nil }
        
        guard let id = currentAnnotation.id else {
            let annotationView = MKAnnotationView(annotation: currentAnnotation, reuseIdentifier: nil)
            let imageView = UIImageView.init(image: #imageLiteral(resourceName: "FirstPrint"))
            
            imageView.frame = CGRect.init(x: annotationView.frame.origin.x + annotationView.frame.width/2 - 20, y: annotationView.frame.origin.y + annotationView.frame.height/2 - 20, width: 40, height: 40)
            
            annotationView.addSubview(imageView)
            
            let annoButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
            annoButton.setImage(#imageLiteral(resourceName: "AddBtn"), for: .normal)
            annotationView.rightCalloutAccessoryView = annoButton
            
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            
            return annotationView
        }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: id) {
            return annotationView
        } else {
            let annotationView = MKAnnotationView(annotation: currentAnnotation, reuseIdentifier: currentAnnotation.id!)
            let imageView = UIImageView.init(image: #imageLiteral(resourceName: "MyPrint"))

            imageView.frame = CGRect.init(x: annotationView.frame.origin.x + annotationView.frame.width/2 - 20, y: annotationView.frame.origin.y + annotationView.frame.height/2 - 20, width: 40, height: 40)
            
            annotationView.addSubview(imageView)
            
            annotationView.detailCalloutAccessoryView = makePhotoView(anno: currentAnnotation)
            
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            
            return annotationView
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let senderAnnotation = view.annotation as? FootPrintAnnotation {
            let view = self.storyboard?.instantiateViewController(withIdentifier: "NewFootPrintViewController") as! NewFootPrintViewController
            view.newAnnotation = senderAnnotation
            self.present(view, animated: true, completion: nil)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension UIImage {
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
