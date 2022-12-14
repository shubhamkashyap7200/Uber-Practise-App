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

private enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeViewControllerDelegate: AnyObject {
    func handleMenuToggle()
}

class HomeViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: HomeViewControllerDelegate?
    private let locationManager = LocationHandler.shared.locationManager
    private var mapView: GMSMapView!
    let marker = GMSMarker()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200.0
    private final let rideActionViewHeight: CGFloat = 300.0
    private var actionButtonConfig = ActionButtonConfig()

    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var searchResultsTitle: [String] = []
    var searchResultsAddress: [String] = []
    var searchResultsCoordinates: [CLLocation] = []
    var searchResultsTitleOfHomeAndWork: [String] = []
    var searchResultsAddressOfHomeAndWork: [String] = []
    
    var searchQueryResult = SearchQueryResult()
    let selectedDriverMarker = GMSMarker()
    let selectedDriverPolyline: GMSPolyline = GMSPolyline()


    //    var location: CLLocation!
    
    public var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
                configureSavedUserLocations()
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

    // MARK: - Indicator View
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    
    // MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

// MARK: - Custom Functions
extension HomeViewController{
    // MARK: - Passenger API
    func startTrip() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (err, ref) in
            self.rideActionView.config = .tripInProgress
            self.selectedDriverPolyline.map = nil
            self.selectedDriverMarker.map = nil
            
            // making a new marker
            let marker = GMSMarker()
            marker.position = trip.destinationCoordinates
            marker.map = self.mapView
            
            // new polyline
            let path = GMSMutablePath()
            path.add(trip.pickUpCoordinates)
            path.add(trip.destinationCoordinates)
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .systemGreen
            polyline.strokeWidth = 4.0
            polyline.map = self.mapView
            
            let bounds = GMSCoordinateBounds(path: path)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 50.0, left: 50.0, bottom: self.rideActionViewHeight * 1.4, right: 50.0)))
            
            self.setCustomRegion(withType: .destination, withCoordinates: trip.destinationCoordinates)
        }
    }
    
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let state = trip.state else { return }
            guard let driverUID =  trip.driverUID else { return }
            
            switch state {
            case .requested:
                break
            case .accepted:
                print("DEBUG:: Trip was accepted")
                self.shouldPresentLoadingView(false)
                Service.shared.fetchUserData(uid: driverUID) { (driver) in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .denied:
                print("DEBUG:: Denied Trip")
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "Oops", withMessage: "It looks like we couldn't find you driver. Plese try again...")
                self.clearTheMapAndRecenterItTheTheUserPosition()
                self.cancelRide()

            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .driverArrived
            case .arrivedDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                self.animateRideActionView(shouldShow: false)
                self.clearTheMapAndRecenterItTheTheUserPosition()
                self.actionButtonConfig = .showView
                self.configureActionButton(config: .showView)
                self.presentAlertController(withTitle: "Trip Completed", withMessage: "We hope you enjoyed your trip")
                break
            }
        }
    }
        
    // MARK: - Driver API
    
    func observeCancelledTrips(trip: Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) {
            self.animateRideActionView(shouldShow: false)
            self.clearTheMapAndRecenterItTheTheUserPosition()
            self.presentAlertController(withTitle: "Oops !!!", withMessage: "The passenger has decided to cancel the trip. \nPress Ok to continue ...")
        }
    }
    
    func observeTrips() {
         DriverService.shared.observeDrivers { (trip) in
            self.trip = trip
        }
    }
    
    func fetchDrivers() {
        var driverArray: [DriverMarker] = []
        guard let location = locationManager?.location else { print("Location is nil"); return }
        PassengerService.shared.fetchDrivers(location: location) { (driver) in
            
            // MARK: - Adding Markers
            guard let location = driver.location?.coordinate else { print("Nil value here"); return }
            let driverMarker = DriverMarker(location: location, uid: driver.uid, title: driver.fullname)
            
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
        
    // MARK: - Configure UI
    
    func configureSavedUserLocations() {
        guard let user = user else { return }
//        searchResultsTitleOfHomeAndWork.removeAll()
//        searchResultsAddressOfHomeAndWork.removeAll()
        
        if let homeLocation = user.homeLocation {
            geocodeAddressString(address: homeLocation)
        }
        
        if let workLocation = user.workLocation {
            geocodeAddressString(address: workLocation)
        }
    }
    
    func geocodeAddressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let clPlacemark = placemarks?.first else { return }
            self.searchResultsTitleOfHomeAndWork.append(clPlacemark.name ?? "Nil Here")
            self.searchResultsAddressOfHomeAndWork.append(clPlacemark.description ?? "Nil Here")
            self.tableView.reloadData()
        }
    }
    
    func configureUI() {
        setupMapView()
        configureRideActionView()
        
        // MARK: - Adding Action Button
        view.addSubview(actionButton)
        actionButton.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 16.0, paddingLeft: 20.0, width: 30.0, height: 30.0)
                
        // MARK: - TableView
        configureTableView()
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
    
    func animateRideActionView(shouldShow: Bool, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
                
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { print("DEBUG:: NIL HERE"); return }

            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.config = config
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
        
    
    // MARK: - Configuring Google Maps
    func setupMapView() {
        // MARK: - Camera and Mapview
        enableLocationServices()
        let camera = GMSCameraPosition.camera(withLatitude: -20.5937, longitude: 78.9629, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        
        guard let location = locationManager?.location?.coordinate else { return }
        marker.position = location
        marker.map = mapView
        mapView.animate(toLocation: marker.position)
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
            print("DEBUG:: Show Menu")
            delegate?.handleMenuToggle()
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

// MARK: - Google maps delegates functions
extension HomeViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG:: Did start monitoring pickup region :: \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG:: Did start monitoring destination region :: \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = self.trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (err, ref) in
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .arrivedDestination) { (err, ref) in
                self.rideActionView.config = .endTrip
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("DEBUG:: Getting called when the location changes :: \(locations.last)")
        
        guard let currentLocation = locations.last else { return }

        marker.position = currentLocation.coordinate
        mapView.animate(toLocation: marker.position)

        guard let user = self.user else { return }
        guard user.accountType == .driver else { return }
        
        DriverService.shared.updateDriverLocation(location: currentLocation)
    }
}



// MARK: - Location Manager
extension HomeViewController {
    // MARK: - Location Manager
    func enableLocationServices() {
        locationManager?.delegate = self
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
        return section == 0 ? "Saved Locations": "Search Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? searchResultsTitleOfHomeAndWork.count : searchQueryResult.name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 0 {
            if !searchResultsTitleOfHomeAndWork.isEmpty && !searchResultsAddressOfHomeAndWork.isEmpty {
                cell.titleLabel.text = searchResultsTitleOfHomeAndWork[indexPath.row]
                cell.subtitleLabel.text = searchResultsAddressOfHomeAndWork[indexPath.row]
            }
        }

        
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
                // FIXME: - Here fix this bug
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

// MARK: - Map Helper functions
private extension HomeViewController {
    func searchBy(naturalLanaguageQuery: String, completion: @escaping ([String], [String], [CLLocationCoordinate2D]) -> Void) {
        var resultsTitle = [String]()
        var resultsAddress = [String]()
        var resultsCoords = [CLLocationCoordinate2D]()
        guard let locationManager = locationManager?.location else { return }
        
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(center: locationManager.coordinate, latitudinalMeters: 2000.0, longitudinalMeters: 2000.0)
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
    func dropoffPassenger() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .completed) { (err, ref) in
            // clearing the map
            // setting user location
            self.clearTheMapAndRecenterItTheTheUserPosition()
            self.animateRideActionView(shouldShow: false)
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func cancelRide() {
        print("DEBUG:: Canceling the trip")
        PassengerService.shared.cancelTrip { (error, reference) in
            if let error = error {
                print("DEBUG: Error while canceling the trip is \(error.localizedDescription)")
                return
            }
            
            self.animateRideActionView(shouldShow: false)
            self.actionButton.setImage(UIImage(systemName: "line.3.horizontal")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showView
            
            self.clearTheMapAndRecenterItTheTheUserPosition()
            self.inputActivationView.alpha = 1.0
        }
    }
    
    func clearTheMapAndRecenterItTheTheUserPosition() {
        mapView.clear()
        if let location = self.locationManager?.location?.coordinate {
            let marker = GMSMarker(position: location)
            marker.map = self.mapView
            self.mapView.animate(toLocation: marker.position)
        }
        
        self.selectedDriverMarker.map = nil
        self.selectedDriverPolyline.map = nil
    }
    
    // MARK: - Creating a region and monitor it
    fileprivate func setCustomRegion(withType type: AnnotationType, withCoordinates coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 100.0, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
    }
    
    func uploadTrip() {
        guard let startCoords = locationManager?.location?.coordinate else { return }
        let endCoords = selectedDriverMarker.position
        
        shouldPresentLoadingView(true, message: "Finding you a ride..")
        
        PassengerService.shared.uploadTripsToFirebase(startCoords: startCoords, endCoords: endCoords) { (err, ref) in
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
        self.trip = trip
        self.trip?.state = .accepted
        
        let marker = GMSMarker()
        marker.position = trip.pickUpCoordinates
        marker.map = mapView
        
        self.setCustomRegion(withType: .pickup, withCoordinates: trip.pickUpCoordinates)

        generatePolylinesAndZoomIn(toDestination: marker.position)
        mapView.animate(toLocation: marker.position)
        
        observeCancelledTrips(trip: trip)
        
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengeerUID) { (passenger) in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
}


extension GMSMarker {
    func giveDriverTag() -> String {
        return "DriverTag"
    }
}
