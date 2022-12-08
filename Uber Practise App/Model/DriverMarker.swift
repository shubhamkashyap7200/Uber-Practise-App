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
    
    init(uid: String) {
        self.uid = uid
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
