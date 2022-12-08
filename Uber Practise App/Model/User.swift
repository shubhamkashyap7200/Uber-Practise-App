//
//  User.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

struct User {
    // MARK: - Properties
    let fullname: String
    let email: String
    let accountType: Int
    
    // MARK: - Methods
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
