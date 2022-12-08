//
//  HomeViewController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/29/22.
//

import UIKit
import Firebase
import GoogleMaps
import FirebaseAuth

private let reuseIdentifier: String = "Location Cell"

class HomeViewController: UIViewController {
    // MARK: - Properties
    private let locationManager = LocationHandler.shared.locationManager
    var mapView: GMSMapView!
    fileprivate var locationMarker : GMSMarker? = GMSMarker()

    //    var location: CLLocation!
    
    
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200.0
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    private let signOutButton: UIButton = { () -> UIButton in
        let btn = UIButton(type: .system)
        btn.setTitle("Sign out", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Indicator View
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    
    // MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        fetchUserData()
        fetchDrivers()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Custom Functions
extension HomeViewController{
    // MARK: - API
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { print("Current uid is nil"); return }
        Service.shared.fetchUserData(uid: uid) { (user) in
            self.user = user
        }
    }
    
    func fetchDrivers() {
        var driverArray: [DriverMarker] = []
        
        guard let location = locationManager?.location else { print("Location is nil"); return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            
            // MARK: - Adding Markers
            guard let location = driver.location?.coordinate else { print("Nil value here"); return }
            let driverMarker = DriverMarker(location: location, uid: driver.uid, title: driver.fullname)
//            driverArray.append(driverMarker)
            print("DEBUG:: \(driverArray)")
            
            // MARK: - Checking if driver already added
            var driverIsVisible: Bool {
                get {
                    return driverArray.contains { driverMarker in
                        if driverMarker.uid == driver.uid {
                            print("DEBUG:: Handle update driver positions")
                            driverMarker.updateMarkerPosition(withCoordinate: location)
                            return true
                        }
                        return false
                    }
                }
            }
            
            print(driverIsVisible)
            
            if !driverIsVisible {
                driverArray.append(driverMarker)
                driverMarker.map = self.mapView
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        let currentUser = Auth.auth().currentUser // Getting current user
        if currentUser?.uid == nil {
            // Navigating to login controller
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
        else {
            print("DEBUG: User is LOGGED in...")
            print("DEBUG: User id is ::: \(currentUser?.uid)")
            configureUI()
        }
    }
    
    func signOut() {
        // Error Handling with do catch block
        do {
            try Auth.auth().signOut()
            let navLogin = UINavigationController(rootViewController: LoginController())
//            navLogin.modalTransitionStyle = .partialCurl
            navLogin.modalPresentationStyle = .fullScreen
            present(navLogin, animated: true)
        }
        catch {
            print("DEBUG: Error in Signout is here ::: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Configure UI
    func configureUI() {
        setupMapView()
        view.addSubview(inputActivationView)
        inputActivationView.customCenterX(inView: view)
        inputActivationView.setDimensions(height: 50.0, width: view.frame.width - 64)
        inputActivationView.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32.0)
        inputActivationView.alpha = 0.0
        inputActivationView.delegate = self
        
        // MARK: - Animations
        UIView.animate(withDuration: 0.75) { [weak self] in
            self?.inputActivationView.alpha = 1.0
        }
        
        // MARK: - TableView
        configureTableView()
        
        // MARK: - Sign out Button
        view.addSubview(signOutButton)
        signOutButton.customAnchor(bottom: view.bottomAnchor, right: view.rightAnchor)
        
    }
    
    @objc func handleSignOut() {
        print("DEBUG:: Signingout")
        signOut()
    }
    
    
    // MARK: - Configuring Google Maps
    func setupMapView() {
        // MARK: - Camera and Mapview
        enableLocationServices()
        let camera = GMSCameraPosition.camera(withLatitude: -20.5937, longitude: 78.9629, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.delegate = self
        locationInputView.customAnchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0.0
        
        // MARK: - Animating View
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1.0
        } completion: { _ in
            print("DEBUG: Present TableView")
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60.0
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
}


// MARK: - Location Manager
extension HomeViewController {
    // MARK: - Location Manager
    func enableLocationServices() {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Some error while getting location")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted:
            print("DEBUG: Some error while getting location as it is restricted")
        case .denied:
            print("DEBUG: Location is denied")
        case .authorizedAlways:
            print("DEBUG: Location is working always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Location is working while in usage")
        default:
            print("DEBUG: Some error")
        }
    }
}

// MARK: - Location Input View Delegate

extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        print("DEBUG: Handle Location Input View")
        inputActivationView.alpha = 0.0
        configureLocationInputView()
    }
}

// MARK: - Location Input View
extension HomeViewController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        dismissKeyboard()
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0.0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1.0
            }
        }
        
    }
}

// MARK: - TableView Functions

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        
        return cell
    }
}

// MARK: - Google Maps Delegate
extension HomeViewController: GMSMapViewDelegate {
}

