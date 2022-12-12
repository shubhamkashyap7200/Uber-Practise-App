//
//  SearchQueryResult.swift
//  Uber Practise App
//
//  Created by Shubham on 12/8/22.
//

import Foundation
import CoreLocation

struct SearchQueryResult {
    var name: [String]
    var address: [String]
    var coordinates: [CLLocation]
    
    
    init() {
        self.name = []
        self.address = []
        self.coordinates = []
    }
}
