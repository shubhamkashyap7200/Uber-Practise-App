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

//// MARK: - Enabling the live preview for UIKit
//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//struct ViewControllerRepresentable: UIViewControllerRepresentable {
//    let hm = HomeViewController()
//    func makeUIViewController(context: Context) -> HomeViewController {
//        return hm
//    }
//
//    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
//        //
//    }
//
//    typealias UIViewControllerType = HomeViewController
//}
//
//@available(iOS 13.0, *)
//struct ViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        ViewControllerRepresentable()
//    }
//}
//
//#endif



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
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200.0
    private final let rideActionViewHeight: CGFloat = 300.0
    private var actionButtonConfig = ActionButtonConfig()

    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var searchResultsTitle: [String] = []
    var searchResultsAddress: [String] = []
    var searchResultsCoordinates: [CLLocation] = []
    var searchQueryResult = SearchQueryResult()
    let selectedDriverMarker = GMSMarker()
    let selectedDriverPolyline: GMSPolyline = GMSPolyline()


    //    var location: CLLocation!
    
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
            } else {
                observeTrips()
            }
        }
    }
    
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let controller = PickupController(trip: trip)
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
            else {
                print("DEBUG:: Show ride action view for accepted..")
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        print("DEBUG:: Trip state is \(trip.state)")
    }

}

// MARK: - Custom Functions
extension HomeViewController{
    // MARK: - API
    
    func observeCurrentTrip() {
        Service.shared.observeCurrentTrip { trip in
            self.trip = trip
            print(trip.state)
            if trip.state == .accepted {
                print("DEBUG:: Trip was accepted")
                self.shouldPresentLoadingView(false)
                
                self.animateRideActionView(shouldShow: true, config: .tripAccepted)
            }
        }
    }
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { print("Current uid is nil"); return }
        Service.shared.fetchUserData(uid: uid) { (user) in
            self.user = user
        }
    }
    
    func observeTrips() {
        Service.shared.observeDrivers { (trip) in
            self.trip = trip
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
//        fetchDrivers()
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
        configureRideActionView()
        
        // MARK: - Adding Action Button
        view.addSubview(actionButton)
        actionButton.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 16.0, paddingLeft: 20.0, width: 30.0, height: 30.0)
        
                
        // MARK: - TableView
        configureTableView()
        
        // MARK: - Sign out Button
        view.addSubview(signOutButton)
        signOutButton.customAnchor(bottom: view.bottomAnchor, right: view.rightAnchor)
        
    }
    
    func configureLocationInputActivationView() {
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
    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func animateRideActionView(shouldShow: Bool, config: RideActionViewConfiguration? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
                
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { print("DEBUG:: NIL HERE"); return }
            rideActionView.configureUI(withConfigure: config)
        }
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
                self.animateRideActionView(shouldShow: false)
            }
            
            // MARK: - Clearing the mapview from driverMarkers and driverPolylines
            self.selectedDriverMarker.map = nil
            self.selectedDriverPolyline.map = nil
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
                self.selectedDriverMarker.position = self.searchQueryResult.coordinates[indexPath.row]
                self.selectedDriverMarker.icon = GMSMarker.markerImage(with: .systemBlue)
                self.selectedDriverMarker.map = self.mapView
                
                self.generatePolylinesAndZoomIn(toDestination: self.selectedDriverMarker.position)
                
                self.animateRideActionView(shouldShow: true, config: .requestRide)
                self.rideActionView.titleLabel.text = self.searchQueryResult.name[indexPath.row]
                self.rideActionView.addressLabel.text = self.searchQueryResult.address[indexPath.row]
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
            request.region = MKCoordinateRegion(center: coord, latitudinalMeters: 250.0, longitudinalMeters: 250.0)
            print("DEBUG:: PP \(request.region)")
        }
        print("DEBUG:: RR \(request.region)")

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
    
    
    func generatePolylinesAndZoomIn(toDestination destination: CLLocationCoordinate2D) {
        if let myLocation = locationManager?.location?.coordinate {
            // MARK: - Creating Polyline
            let path = GMSMutablePath()
            path.add(myLocation)
            path.add(destination)
            selectedDriverPolyline.path = path
            selectedDriverPolyline.strokeColor = .systemBlue
            selectedDriverPolyline.strokeWidth = 4.0
            selectedDriverPolyline.map = mapView
            
            // MARK: - Zooming in
            let bounds = GMSCoordinateBounds(path: path)
//            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 50.0, left: 50.0, bottom: rideActionViewHeight * 1.4, right: 50.0)))
        }
    }
}

// MARK: - Uploading the trips to firebase

extension HomeViewController: RideActionViewDelegate {
    func uploadTrip() {
        guard let startCoords = locationManager?.location?.coordinate else { return }
        let endCoords = selectedDriverMarker.position
        
        shouldPresentLoadingView(true, message: "Finding you a ride..")
        
        Service.shared.uploadTripsToFirebase(startCoords: startCoords, endCoords: endCoords) { (err, ref) in
            if let error = err {
                print("DEBUG:: \(error.localizedDescription)")
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
}


// MARK: - PickupControllerDelegate

extension HomeViewController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip?.state = .accepted
        
        let marker = GMSMarker()
        marker.position = trip.pickUpCoordinates
        marker.map = mapView
        
        generatePolylinesAndZoomIn(toDestination: marker.position)
        mapView.animate(toLocation: marker.position)
        
        
        self.dismiss(animated: true) {
            self.animateRideActionView(shouldShow: true, config: .tripAccepted)
        }
    }
}
