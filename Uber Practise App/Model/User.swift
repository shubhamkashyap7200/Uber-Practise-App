//
//  User.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

import CoreLocation
enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    // MARK: - Properties
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    var homeLocation: String?
    var workLocation: String?
    var firstIntial: String { return String(fullname.prefix(1)) }
    
    // MARK: - Methods
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountTypeIndex"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
        
        if let home = dictionary["homeLocation"] as? String {
            self.homeLocation = home
        }
        
        if let work = dictionary["workLocation"] as? String {
            self.workLocation = work
        }
    }
}
