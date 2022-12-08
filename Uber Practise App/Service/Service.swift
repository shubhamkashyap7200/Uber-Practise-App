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
                    completion(user)
                }
            })
        }
    }
}
