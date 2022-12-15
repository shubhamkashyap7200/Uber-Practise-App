//
//  PickupController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/15/22.
//

import UIKit
import GoogleMaps

class PickupController: UIViewController, GMSMapViewDelegate {
    // MARK: - Properties
    private let mapView = GMSMapView()
    private let trip: Trip
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let
    
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

    // MARK: - API

    
    // MARK: - Helper Functions
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelButton)
        cancelButton.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16.0, width: 32.0, height: 32.0)
        configureMapView()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.setDimensions(height: 270.0, width: 270.0)
        mapView.camera = GMSCameraPosition.camera(withLatitude: 37.0902, longitude: 95.7129, zoom: 4.0)
        mapView.layer.cornerRadius = 270 / 2
        mapView.customCenterX(inView: view)
        mapView.customCenterY(inView: view)
//        mapView.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32.0)
    }
}
