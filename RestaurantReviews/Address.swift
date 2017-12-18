//
//  Address.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

struct Address {
    let address1: String
    let address2: String?
    let address3: String?
    let crossStreets: String?
    let city: String
    let zip: String
    let country: String
    let state: String
    let display: String
}

extension Address: JSONDecodable {
    init?(json: [String : Any]) {
        guard let street = json["address1"] as? String,
            let city = json["city"] as? String,
            let zip = json["zip_code"] as? String,
            let country = json["country"] as? String,
            let state = json["state"] as? String,
            let display = json["display_address"] as? [String]
            else { return nil }
        
        self.address1 = street
        self.address2 = json["address2"] as? String
        self.address3 = json["address3"] as? String
        self.crossStreets = json["cross_streets"] as? String
        self.city = city
        self.zip = zip
        self.country = country
        self.state = state
        self.display = display.joined(separator: "\n")
    }
}
