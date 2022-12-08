//
//  Service.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

import Firebase
import FirebaseAuth

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")

struct Service {
    // MARK: - Properties
    static let shared = Service()
    
    // MARK: - Methods
    func fetchUserData(completion: @escaping(User) -> Void) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { print("NIL HERE"); return }
        REF_USERS.child(currentUID).observeSingleEvent(of: .value) { (snapshot)  in
            // MARK: - Completetion block
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            let user = User(dictionary: dictionary)
            
            completion(user)
        }
    }
}
