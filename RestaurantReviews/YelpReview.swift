//
//  YelpReview.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

class YelpReview: JSONDecodable {
    let url: String
    let text: String
    let rating: Int
    var user: YelpUser
    let creationTime: Date
    
    required init?(json: [String : Any]) {
        guard let url = json["url"] as? String, let text = json["text"] as? String, let rating = json["rating"] as? Int, let userDict = json["user"] as? [String: Any], let timeCreated = json["time_created"] as? String else { return nil }
        
        self.url = url
        self.text = text
        self.rating = rating
        
        guard let user = YelpUser(json: userDict) else { return nil }
        self.user = user
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let creationTime = formatter.date(from: timeCreated) else { return nil }
        self.creationTime = creationTime
    }
    
    func update(_ user: YelpUser) {
        self.user = user
    }
}
