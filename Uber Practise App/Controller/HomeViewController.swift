//
//  HomeViewController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/29/22.
//

import UIKit
import Firebase
import GoogleMaps

class HomeViewController: UIViewController, GMSMapViewDelegate {
    // MARK: - Properties
    let locationManager = CLLocationManager()
    
    // MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
//        signOut()
        checkIfUserIsLoggedIn()
    }
}

// MARK: - Custom Functions
extension HomeViewController{
    func checkIfUserIsLoggedIn() {
        let currentUser = Auth.auth().currentUser // Getting current user
        if currentUser?.uid == nil {
            // Navigating to login controller
            let navLogin = UINavigationController(rootViewController: LoginController())
            navLogin.modalTransitionStyle = .partialCurl
            navLogin.modalPresentationStyle = .fullScreen
            present(navLogin, animated: true)
            print("DEBUG: User not logged in...")
        }
        else {
            print("DEBUG: User is LOGGED in...")
            print("DEBUG: User id is ::: \(currentUser?.uid)")
            setupMapView()
        }
    }
    
    func signOut() {
        // Error Handling with do catch block
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("DEBUG: Error in Signout is here ::: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Configuring Google Maps
    func setupMapView() {
        // MARK: - Camera and Mapview
        enableLocationServices()

        let camera = GMSCameraPosition.camera(withLatitude: -33.87, longitude: 151.8, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
}


// MARK: - Location Manager
extension HomeViewController: CLLocationManagerDelegate {
    // MARK: - Location Manager
    func enableLocationServices() {
        locationManager.delegate = self
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Some error while getting location")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("DEBUG: Some error while getting location as it is restricted")
        case .denied:
            print("DEBUG: Location is denied")
        case .authorizedAlways:
            print("DEBUG: Location is working always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Location is working while in usage")
        default:
            print("DEBUG: Some error")
        }
    }

    
    // MARK: - Location Delegates
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            // Asking for always location
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        if let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude {
            let camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 17.0)
            let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
            mapView.animate(to: camera)
            locationManager.stopUpdatingLocation()
        }
    }
}
