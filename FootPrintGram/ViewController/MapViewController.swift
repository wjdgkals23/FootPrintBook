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
    var addPinButton: UIButton! = UIButton()
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
        addPinButton.setImage(#imageLiteral(resourceName: "PinPoint"), for: .normal)
        
        mapView.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(addPinButton.snp.top)
        }
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        rightMove.addTarget(self, action: #selector(rightMoving), for: .touchUpInside)
        addPinButton.addTarget(self, action: #selector(addPin), for: .touchUpInside)
        
        let mapTap = UITapGestureRecognizer.init(target: self, action: #selector(modifyPin))
        mapView.addGestureRecognizer(mapTap)
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
            lastAnnotation = FootPrintAnnotation.init(coordinate: locationManager.location!.coordinate, title: "New Point")
            self.mapView.addAnnotation(lastAnnotation)
        }
    }
    
    @objc func modifyPin() {
        if lastAnnotation != nil {
            mapView.removeAnnotation(lastAnnotation)
            lastAnnotation = nil
        }
    }
    
    @objc func centerToUsersLocation() {
        let center = mapView.userLocation.coordinate
        let zoomRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(zoomRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
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
