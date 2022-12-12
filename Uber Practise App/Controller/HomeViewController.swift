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
import GooglePlaces
import MapKit

private let reuseIdentifier: String = "Location Cell"
private enum ActionButtonConfig {
    case showView
    case dismissActionView
    
    init() {
        self = .showView
    }
}

class HomeViewController: UIViewController {
    // MARK: - Properties
    private let locationManager = LocationHandler.shared.locationManager
    private var mapView: GMSMapView!
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var searchResultsTitle: [String] = []
    var searchResultsAddress: [String] = []
    var searchResultsCoordinates: [CLLocation] = []
    
    var searchQueryResult = SearchQueryResult()
    

    //    var location: CLLocation!
    
    
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200.0
    private var actionButtonConfig = ActionButtonConfig()
    
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    // MARK: - Action Button
    private let actionButton: UIButton = { () -> UIButton in
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "line.3.horizontal")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return btn
    }()

    
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
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
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
//        var bounds = GMSCoordinateBounds()
        
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
//                bounds = bounds.includingCoordinate(driverMarker.position)
                driverMarker.map = self.mapView
            }
        }
        
//        let update = GMSCameraUpdate.fit(bounds, withPadding: 5.0)
//        mapView.animate(with: update)
//        mapView.setMinZoom(1, maxZoom: 20)
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
            configureAll()
        }
    }
    
    func configureAll() {
        configureUI()
        fetchUserData()
        fetchDrivers()
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
        
        // MARK: - Adding Action Button
        view.addSubview(actionButton)
        actionButton.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 16.0, paddingLeft: 20.0, width: 30.0, height: 30.0)
        
        
        view.addSubview(inputActivationView)
        inputActivationView.customCenterX(inView: view)
        inputActivationView.setDimensions(height: 50.0, width: view.frame.width - 64.0)
        inputActivationView.customAnchor(top: actionButton.bottomAnchor, paddingTop: 10.0)
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
    
    fileprivate func configureActionButton(config: ActionButtonConfig) {
        switch config {
        case .showView:
            self.inputActivationView.alpha = 1.0
            self.actionButton.setImage(UIImage(systemName: "line.3.horizontal")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
            
        case .dismissActionView:
            actionButton.setImage(UIImage(systemName: "arrow.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
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
        tableView.allowsSelection = true
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool) ->  Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0.0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    @objc func handleActionButton() {
        switch actionButtonConfig {
        case .showView:
            print("DEBUG:: Show view")
        case .dismissActionView:
            print("DEBUG:: dismiss View")
            UIView.animate(withDuration: 0.3) {
                self.configureActionButton(config: .showView)
            }
            mapView.clear()
        }
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
    // MARK: - Search Query Function
    func executeSearch(query: String) {
        print("DEBUG:: Query is here \(query)")
        searchBy(naturalLanaguageQuery: query) { (resultsTitle, resultsAddress, resultsCoords)  in
            
            self.searchQueryResult.name = resultsTitle
            self.searchQueryResult.address = resultsAddress
            self.searchQueryResult.coordinates = resultsCoords
            
            print("DEBUG:: VIEW \(self.searchQueryResult.coordinates)")
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissKeyboard()
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.inputActivationView.alpha = 1.0
            })
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
        return (section == 0) ? 2 : searchQueryResult.name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
        
            if !searchQueryResult.name.isEmpty && !searchQueryResult.address.isEmpty {
                cell.titleLabel.text = searchQueryResult.name[indexPath.row]
                cell.subtitleLabel.text = searchQueryResult.address[indexPath.row]
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        configureActionButton(config: .dismissActionView)
        
        dismissLocationView { _ in
            if !self.searchQueryResult.coordinates.isEmpty {
                let marker = GMSMarker()
                marker.position = self.searchQueryResult.coordinates[indexPath.row]
                marker.icon = GMSMarker.markerImage(with: .systemBlue)
                marker.map = self.mapView
                
                self.mapView.selectedMarker = marker
                
                self.generatePolylines(toDestination: marker.position)
            }
        }
    }
}

// MARK: - Google Maps Delegate
extension HomeViewController: GMSMapViewDelegate {
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        mapView.animate(toLocation: (locationManager?.location!.coordinate)!)
//    }
}


// MARK: - Map Helper functions
private extension HomeViewController {
    func searchBy(naturalLanaguageQuery: String, completion: @escaping ([String], [String], [CLLocationCoordinate2D]) -> Void) {
        var resultsTitle = [String]()
        var resultsAddress = [String]()
        var resultsCoords = [CLLocationCoordinate2D]()
        
        let request = MKLocalSearch.Request()
        if let coord = locationManager?.location?.coordinate {
            request.region = MKCoordinateRegion(center: coord, latitudinalMeters: CLLocationDistance(floatLiteral: 10.0), longitudinalMeters: CLLocationDistance(floatLiteral: 10.0))
            print("DEBUG:: \(request.region)")
        }
        print("DEBUG:: \(request.region)")

        request.naturalLanguageQuery = naturalLanaguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach { item in
                resultsTitle.append(item.placemark.name ?? "No Data")
                resultsAddress.append(item.placemark.title ?? "NOOO DATA")
                resultsCoords.append(item.placemark.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
            }
            completion(resultsTitle, resultsAddress, resultsCoords)
        }
    }
    
    
    func generatePolylines(toDestination destination: CLLocationCoordinate2D) {
        if let myLocation = locationManager?.location?.coordinate {
            let newPath = GMSMutablePath()
            newPath.add(myLocation)
            newPath.add(destination)
            let polyline: GMSPolyline = GMSPolyline(path: newPath)
            polyline.strokeColor = .systemBlue
            polyline.strokeWidth = 4.0
            polyline.map = mapView
        }
    }
}

