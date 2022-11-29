//
//  HomeViewController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/29/22.
//

import UIKit
import Firebase
import GoogleMaps

class HomeViewController: UIViewController {
    // MARK: - Properties
    
    
    // MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
//        signOut()
        setupMapView()
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
        let camera = GMSCameraPosition.camera(withLatitude: -33.87, longitude: 151.8, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
    }
}
