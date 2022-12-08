//
//  User.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

import CoreLocation

struct User {
    // MARK: - Properties
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    let uid: String
    
    // MARK: - Methods
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
