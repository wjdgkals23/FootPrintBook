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

class MapViewController: UIViewController {
    
    var mapView: MKMapView! = MKMapView()
    var addPinButton: UIView! = UIView()
    var rightMove: UIButton! = UIButton()
    
    var lastAnnotation: FootPrintAnnotation!
    
    let regionInMeters: CLLocationDistance = 500
    
    var locationManager = CLLocationManager()
    var userLocated = false
    
    weak var alertManager = MakeAlert.shared
    
    func setupView() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(addPinButton)
        self.view.addSubview(mapView)
        
        addPinButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(80)
        }
        addPinButton.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "AddPin"))
        addPinButton.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(addPinButton)
            make.centerY.equalTo(addPinButton)
            make.width.equalTo(40)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(addPinButton.snp.top)
        }
        
        let removeButton = UIImageView.init(image: #imageLiteral(resourceName: "RemovePin"))
        removeButton.isUserInteractionEnabled = true
        let mapTap = UITapGestureRecognizer.init(target: self, action: #selector(modifyPin))
        removeButton.addGestureRecognizer(mapTap)
        mapView.addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(mapView).offset(-10)
            make.width.equalTo(50)
        }
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        rightMove.addTarget(self, action: #selector(rightMoving), for: .touchUpInside)
        
        let addPinTap = UITapGestureRecognizer.init(target: self, action: #selector(addPin))
        addPinButton.addGestureRecognizer(addPinTap)
    }
    
    @objc func rightMoving() {
//        location
    }
    
    func checkLocationAuthorization() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // delegate setting
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        setupView()
        checkLocationAuthorization()
    }
    
    @objc func addPin() {
        centerToUsersLocation()
        if lastAnnotation != nil {
            alertManager?.makeOneActionAlert(target: self, title: "Annotation already dropped", message: "There is an annotation on screen. Tap the Map If you want Remove Annotation", dismiss: true)
        } else {
            lastAnnotation = FootPrintAnnotation.init(coordinate: locationManager.location!.coordinate, title: "New Post", subtitle: "Touch To Add Post")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewFootPrint" {
            let destination = segue.destination as! NewFootPrintViewController
            let senderAnnotation = sender as! FootPrintAnnotation
            destination.newAnnotation = senderAnnotation
        }
    }
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {
        if segue.identifier == "cancel" {
            print("cancel")
        } else {
            
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let title = annotation.title! else {
            return nil
        }
        
        if (annotation is FootPrintAnnotation) {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: title) {
                return annotationView
            } else {
                let currentAnnotation = annotation as! FootPrintAnnotation
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: title)
                
                var flagImage = #imageLiteral(resourceName: "ExistFlag")
                
                if currentAnnotation.title == "New Post" {
                    annotationView.isDraggable = true
                    flagImage = #imageLiteral(resourceName: "EmptyFlag")
                }
                
                let imageView = UIImageView.init(image: flagImage)
                imageView.frame = CGRect.init(x: annotationView.frame.origin.x + annotationView.frame.width/2 - 25, y: annotationView.frame.origin.y + annotationView.frame.height/2 - 25, width: 50, height: 50)
                
                annotationView.addSubview(imageView)
                
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                
                let detailDisclosure = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = detailDisclosure
                
                return annotationView
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let footprintAnnotation = view.annotation as? FootPrintAnnotation {
            performSegue(withIdentifier: "NewFootPrint", sender: footprintAnnotation)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
