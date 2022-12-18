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
}
