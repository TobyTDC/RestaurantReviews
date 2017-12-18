//
//  YelpClient.swift
//  RestaurantReviews
//
//  Created by toby tang on 2017-12-17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

class YelpClient: APIClient {
    let session: URLSession
    private let token: String
    
    init(configuration: URLSessionConfiguration, oauthToken: String) {
        self.session = URLSession(configuration: configuration)
        self.token = oauthToken
    }
    
    convenience init(oauthToken: String) {
        self.init(configuration: .default, oauthToken: oauthToken)
    }
    
    func search(withTerm term: String, at coordinate: Coordinate, categories: [YelpCategory] = [], radius: Int? = nil, limit: Int = 50, sortBy sortType: Yelp.YelpSortType = .rating, completion: @escaping (Result<[YelpBusiness], APIError>) -> Void){
        
        let endpoint = Yelp.search(term: term, coordinate: coordinate, radius: radius, categories: categories, limit: limit, sortBy: sortType)
        
        let request = endpoint.requestWithAuthorizationHeader(oauthToken: token)
        
        fetch(with: request, parse: { json -> [YelpBusiness] in
            guard let businesses = json["businesses"] as? [[String: Any]] else { return [] }
            return businesses.flatMap { YelpBusiness(json: $0) }
            
        }, completion: completion)
        
    }
    
    func businessWithId(_ id: String, completion: @escaping (Result<YelpBusiness, APIError>) -> Void) {
        let endpoint = Yelp.business(id: id)
        let request = endpoint.requestWithAuthorizationHeader(oauthToken: self.token)
        
        fetch(with: request, parse: { json -> YelpBusiness? in
            return YelpBusiness(json:json)
        }, completion: completion)
    }
    
    func updateWithHoursAndPhotos(_ business: YelpBusiness, completion: @escaping (Result<YelpBusiness, APIError>) -> Void){
        let endpoint = Yelp.business(id: business.id)
        let request = endpoint.requestWithAuthorizationHeader(oauthToken: self.token)
        
        fetch(with: request, parse: { json -> YelpBusiness? in
            business.updateWithHoursAndPhotos(json: json)
            return business
        }, completion: completion)
    }
    
    func reviews(for bussiness: YelpBusiness, completion: @escaping (Result<[YelpReview], APIError>) -> Void){
        let endpoint = Yelp.reviews(businessId: bussiness.id)
        let request = endpoint.requestWithAuthorizationHeader(oauthToken: self.token)
        
        fetch(with: request, parse: {
            json -> [YelpReview] in
            guard let reviews = json["reviews"] as? [[String: Any]] else { return [] }
            return reviews.flatMap {
                YelpReview(json:  $0)
            }
        }, completion: completion)
    }
    
}













