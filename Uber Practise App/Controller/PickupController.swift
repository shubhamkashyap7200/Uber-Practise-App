//
//  PickupController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/15/22.
//

import UIKit
import GoogleMaps

protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController, GMSMapViewDelegate {
    // MARK: - Properties
    private let mapView = GMSMapView()
    private let trip: Trip
    weak var delegate: PickupControllerDelegate?
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var circularProgressView: CircularProgressView = { () -> CircularProgressView in
        let cp = CircularProgressView(frame: .zero)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268.0, width: 268.0)
        mapView.layer.cornerRadius = 268.0 / 2
        mapView.customCenterX(inView: cp)
        mapView.customCenterY(inView: cp, constant: 32.0)
        
        
        return cp
    }()
    
    private let pickupLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = { () -> UIButton in
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Accept Trip", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12.0
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = { () -> UIButton in
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "x.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG:: Trip passenger uid is :: \(trip.passengeerUID)")
        configureUI()
    }
        
    // MARK: - Selectors
    @objc func handleDismiss() {
        print("DEBUG:: Dismissing")
        dismiss(animated: true)
    }
    
    @objc func handleAcceptTrip() {
        print("DEBUG:: Accepting")
        DriverService.shared.acceptTrip(trip: trip) { (error, reference) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }

    // MARK: - API

    
    // MARK: - Helper Functions
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelButton)
        cancelButton.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16.0, width: 32.0, height: 32.0)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360.0, width: 360.0)
        circularProgressView.customCenterX(inView: view)
        circularProgressView.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32.0)
        configureMapView()
        
        view.addSubview(pickupLabel)
        pickupLabel.customAnchor(top: circularProgressView.bottomAnchor, paddingTop: 32.0)
        pickupLabel.customCenterX(inView: view)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.customAnchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16.0, paddingLeft: 32.0, paddingRight: 32.0, height: 56.0)
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: trip.pickUpCoordinates.latitude, longitude: trip.pickUpCoordinates.longitude, zoom: 17.0)
        mapView.camera = camera
        mapView.animate(to: camera)
        
        let marker = GMSMarker(position: trip.pickUpCoordinates)
        marker.map = mapView
        mapView.selectedMarker = marker
    }
}
