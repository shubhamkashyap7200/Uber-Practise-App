//
//  TRip.swift
//  Uber Practise App
//
//  Created by Shubham on 12/13/22.
//

import Foundation
import CoreLocation

enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
}


struct Trip {
    var pickUpCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengeerUID: String!
    var driverUID: String?
    var state: TripState!
    
    
    init(passengerUID: String, dictionary: [String: Any]) {
        self.passengeerUID = passengerUID
        
        if let pickUpCoordinates = dictionary["pickUpCoordinates"] as? NSArray {
            guard let lat = pickUpCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickUpCoordinates[1] as? CLLocationDegrees else { return }
            
            self.pickUpCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUID = dictionary["driverUID"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}
