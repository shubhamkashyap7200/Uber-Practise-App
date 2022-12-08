//
//  LocationHandler.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

import Foundation
import CoreLocation


class LocationHandler: NSObject, CLLocationManagerDelegate {
    static let shared = LocationHandler()
    
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    // MARK: - Location Functions

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager?.authorizationStatus == .authorizedWhenInUse {
            // Asking for always location
            locationManager?.requestAlwaysAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEGUB: We got an error here ::: \(error.localizedDescription)")
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        mapView.clear()
//        location = locations.last
//
//        if let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude {
//            marker.position.latitude = latitude
//            marker.position.longitude = longitude
//            marker.map = mapView
//            marker.title = "Hello"
//            mapView.animate(to: GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0))
//        }
//    }

}
