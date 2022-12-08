//
//  DriverAnnotation.swift
//  Uber Practise App
//
//  Created by Shubham on 12/8/22.
//

import GoogleMaps

class DriverMarker: GMSMarker {
//    // MARK: - Properties
    var uid: String
    
    init(location: CLLocationCoordinate2D, uid: String, title: String) {
        self.uid = uid
        super.init()
        self.position = location
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update Marker Position
    func updateMarkerPosition(withCoordinate location: CLLocationCoordinate2D) {
        // dynamic marker
        UIView.animate(withDuration: 0.2) {
            self.position = location
        }
    }
}
