//
//  YelpBusiness.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

class YelpBusiness: NSObject, JSONDecodable {
    let id: String
    let name: String
    let imageUrl: String
    let isClosed: Bool
    let url: String
    let reviewCount: Int
    let categories: [YelpCategory]
    let rating: Double
    let location: Coordinate
    let transactions: [YelpTransaction]
    let address: Address
    let phone: String
    let displayPhone: String
    let price: String
    
    // Only available through search results not direct business queries
    var distance: Double?
    
    // Detail properties
    var photos: [String]
    var hours: BusinessHours?
    var reviews: [YelpReview]
    
    required init?(json: [String : Any]) {
        guard let id = json["id"] as? String,
            let name = json["name"] as? String,
            let imageUrl = json["image_url"] as? String,
            let isClosed = json["is_closed"] as? Bool,
            let url = json["url"] as? String,
            let reviewCount = json["review_count"] as? Int,
            let categoriesDict = json["categories"] as? [[String: Any]],
            let rating = json["rating"] as? Double,
            let coordinatesDict = json["coordinates"] as? [String: Any],
            let coordinates = Coordinate(json: coordinatesDict),
            let transactionValues = json["transactions"] as? [String],
            let location = json["location"] as? [String: Any],
            let address = Address(json: location),
            let price = json["price"] as? String,
            let phone = json["phone"] as? String,
            let displayPhone = json["display_phone"] as? String
            else { return nil }
        
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.isClosed = isClosed
        self.url = url
        self.reviewCount = reviewCount
        self.categories = categoriesDict.compactMap { YelpCategory(json: $0) }
        self.rating = rating
        self.location = coordinates
        self.transactions = transactionValues.compactMap { YelpTransaction(rawValue: $0) }
        self.address = address
        self.phone = phone
        self.displayPhone = displayPhone
        self.price = price
        
        self.distance = json["distance"] as? Double
        self.photos = json["photos"] as? [String] ?? []
        
        if let hours = json["hours"] as? [[String: Any]], let dict = hours.first {
            self.hours = BusinessHours(json: dict)
        }
        
        self.reviews = []
        
        super.init()
    }
    
    func updateWithHoursAndPhotos(json: [String: Any]) {
        if let photoStrings = json["photos"] as? [String] {
            photos = photoStrings
        }
        
        if let hours = json["hours"] as? [[String: Any]], let dict = hours.first {
            self.hours = BusinessHours(json: dict)
        }
    }
}

import MapKit

extension YelpBusiness: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return isClosed ? "Closed" : "Open"
    }
}



