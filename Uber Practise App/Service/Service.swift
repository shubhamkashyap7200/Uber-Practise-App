//
//  Service.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

import Firebase
import FirebaseAuth
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    // MARK: - Properties
    static let shared = Service()
    let geofireRadius: Double = 50.0
    
    // MARK: - Methods
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot)  in
            // MARK: - Completetion block
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    
    // MARK: - Fetch Drivers
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        REF_DRIVER_LOCATION.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: geofireRadius).observe(.keyEntered, with: { uid, location in
                //
                print("DEBUG:: uid is \(uid), location is \(location.coordinate)")
                self.fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    
    // MARK: - Upload the trips to firebase
    func uploadTripsToFirebase(startCoords pickUpCoordinates: CLLocationCoordinate2D, endCoords destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickUpArray = [pickUpCoordinates.latitude, pickUpCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values: [String : Any] = [
            "pickUpCoordinates": pickUpArray,
            "destinationCoordinates": destinationArray,
            "state": TripState.requested.rawValue
        ]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }

    
    func observeDrivers(completion: @escaping(Trip) -> Void){
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            
            let trip = Trip(passengerUID: uid, dictionary: dictionary)
            
            print("DEBUG:: Trip state is :: \(trip.state)")
            completion(trip)
        }
    }
    
    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {
        REF_TRIPS.child(trip.passengeerUID).observeSingleEvent(of: .childRemoved) { _ in
            print("DEBUG:: Deleted the trip ...")
            completion()
        }
    }
    
    
    func acceptTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": uid, "state": TripState.accepted.rawValue] as [String : Any]
        
        REF_TRIPS.child(trip.passengeerUID).updateChildValues(values) { (error, reference) in
            if let error = error {
                print("DEBUG:: Error while accepting the trip : \(error.localizedDescription)")
                return
            }
            
            REF_TRIPS.child(trip.passengeerUID).updateChildValues(values, withCompletionBlock: completion)
        }
    }
    
    func observeCurrentTrip(completetion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUID: uid, dictionary: dictionary)
            completetion(trip)
        }
    }
    
    func cancelTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
}
