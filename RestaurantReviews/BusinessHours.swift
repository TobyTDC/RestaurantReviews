//
//  BusinessHours.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

struct BusinessHours {
    enum HoursType {
        case regular
        
        init?(string: String) {
            switch string {
            case "REGULAR": self = .regular
            default: return nil
            }
        }
    }
    
    struct Schedule {
        enum Day: Int {
            case monday = 0
            case tuesday
            case wednesday
            case thursday
            case friday
            case saturday
            case sunday
        }
        
        let isOvernight: Bool
        let start: String
        let end: String
        let day: Day
    }
    
    let schedule: [Schedule]
    let type: HoursType
    let isOpenNow: Bool
}

extension BusinessHours.Schedule: JSONDecodable {
    init?(json: [String : Any]) {
        guard let isOvernight = json["is_overnight"] as? Bool, let start = json["start"] as? String, let end = json["end"] as? String, let dayValue = json["day"] as? Int, let day = BusinessHours.Schedule.Day(rawValue: dayValue) else { return nil }
        
        self.isOvernight = isOvernight
        self.start = start
        self.end = end
        self.day = day
    }
}

extension BusinessHours: JSONDecodable {
    init?(json: [String : Any]) {
        guard let openHours = json["open"] as? [[String: Any]], let hoursTypeString = json["hours_type"] as? String, let hoursType = HoursType(string: hoursTypeString), let isOpenNow = json["is_open_now"] as? Bool else { return  nil }
        
        self.type = hoursType
        self.isOpenNow = isOpenNow
        self.schedule = openHours.flatMap { BusinessHours.Schedule(json: $0) }
    }
}
