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

class MapViewController: UIViewController {
    
    var mapView: MKMapView! = MKMapView()

    var lastAnnotation: FootPrintAnnotation!
    
    let regionInMeters: CLLocationDistance = 250
    
    var locationManager = CLLocationManager()
    var userLocated = false
    
    var userInfo = UserInfo.shared
    var mainData: FootPrintAnnotationList!
    var ref = Database.database().reference()
    
    var lastData: NSDictionary!
    
    weak var alertManager = MakeAlert.shared
    
    var annotationImageDict: [String:UIImage] = [String:UIImage]()
    
    
    // MARK: - Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // delegate setting
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mainData = FootPrintAnnotationList.shared
        
        setupView()
        checkLocationAuthorization()
        getAnnotation()
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
    
    private func getAnnotation() {
        let group = DispatchGroup()
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        group.enter()
        DispatchQueue.global().async { [unowned self] in
            self.ref.child("footprintPosts").child(self.userInfo.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if(!snapshot.exists()) {
                    group.leave()
                }
                guard let value = (snapshot.value as? NSDictionary) else { return }
                if(value != self.lastData) {
                    self.lastData = value
                    self.mainData.fpaList = [FootPrintAnnotation]()
                    for item in value.allValues {
                        let it = item as! NSDictionary
                        let cood = CLLocationCoordinate2D.init(latitude: Double(it["latitude"] as! String)! as CLLocationDegrees, longitude: Double(it["longitude"] as! String)! as CLLocationDegrees)
                        let title = it["name"] as? String
                        let imageUrl = it["profileImageURL"] as? String
                        let item = FootPrintAnnotation.init(coordinate: cood, title: title!, imageUrl: imageUrl!)
                        self.mainData.fpaList?.append(item)
                    }
                    self.loadImage()
                }
            group.leave()
        }, withCancel: nil)
            group.notify(queue: .main) {
                print("load Done")
                self.view.isUserInteractionEnabled = true
                self.mapView.showAnnotations(self.mainData.fpaList!, animated: true)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func loadImage() {
        for item in self.mainData.fpaList! {
            let url = URL.init(string: item.post.imageUrl!)
            let data = NSData.init(contentsOf: url!)
            let image = UIImage(data: data! as Data)
            self.annotationImageDict[item.post.title!] = image
        }
    }
    
    // MARK: - Gesture Func
    
    @objc func swipeUp(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .up {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "AnnotationTableViewController") as! AnnotationTableViewController
                self.present(view, animated: true, completion: nil)
            }
        }
    }
    
    @objc func addPin() {
        centerToUsersLocation()
        if lastAnnotation != nil {
            alertManager?.makeOneActionAlert(target: self, title: "Annotation already dropped", message: "There is an annotation on screen. Tap the Map If you want Remove Annotation", dismiss: true)
        } else {
            lastAnnotation = FootPrintAnnotation.init(coordinate: locationManager.location!.coordinate, title: "New Post", imageUrl: nil)
            self.mapView.addAnnotation(lastAnnotation)
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
    
    @objc func centerToUsersLocation() {
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
            lastAnnotation = nil
            getAnnotation()
        }
    }
}

// MARK: - Delegate Func

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let title = annotation.title! else { return nil }
        
        if (annotation is FootPrintAnnotation) {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: title) {
                return annotationView
            } else {
                let currentAnnotation = annotation as! FootPrintAnnotation
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: title)
                let imageView = UIImageView.init(image: currentAnnotation.post.imageUrl! == "@default" ? #imageLiteral(resourceName: "FirstPrint") : #imageLiteral(resourceName: "MyPrint"))
                if currentAnnotation.post.imageUrl! == "@defalut" {
                    imageView.tintColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                }
                imageView.frame = CGRect.init(x: annotationView.frame.origin.x + annotationView.frame.width/2 - 20, y: annotationView.frame.origin.y + annotationView.frame.height/2 - 20, width: 40, height: 40)
                
                annotationView.addSubview(imageView)
                
                let annoButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
                annoButton.setImage(#imageLiteral(resourceName: "AddBtn"), for: .normal)

                if(annotationImageDict[title] != nil) {
                    annoButton.setImage(annotationImageDict[title], for: .normal)
                }
                
                annotationView.rightCalloutAccessoryView = annoButton
                
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                
                
                return annotationView
            }
        }
        return nil
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
