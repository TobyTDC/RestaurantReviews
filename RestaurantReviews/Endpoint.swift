//
//  Endpoint.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

/// A type that provides URLRequests for defined API endpoints
protocol Endpoint {
    /// Returns the base URL for the API as a string
    var base: String { get }
    /// Returns the URL path for an endpoint, as a string
    var path: String { get }
    /// Returns the URL parameters for a given endpoint as an array of URLQueryItem
    /// values
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    /// Returns an instance of URLComponents containing the base URL, path and
    /// query items provided
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = queryItems
        
        return components
    }
    
    /// Returns an instance of URLRequest encapsulating the endpoint URL. This 
    /// URL is obtained through the `urlComponents` object.
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
    
    func requestWithAuthorizationHeader(oauthToken: String) -> URLRequest {
        var oauthRequest = request
        
        oauthRequest.addValue("Bearer \(oauthToken)", forHTTPHeaderField: "Authorization")
        
        return oauthRequest
    }
    
}

enum Yelp {
    enum YelpSortType: CustomStringConvertible {
        case bestMatch, rating, reviewCount, distance
        
        var description: String {
            switch self {
            case .bestMatch: return "best_match"
            case .rating: return "rating"
            case .reviewCount: return "review_count"
            case .distance: return "distance"
            }
        }
    }
    
    case search(term: String, coordinate: Coordinate, radius: Int?, categories: [YelpCategory], limit: Int?, sortBy: YelpSortType?)
    case business(id: String)
    case reviews(businessId: String)
}

extension Yelp: Endpoint {
    var base: String {
        return "https://api.yelp.com"
    }
    
    var path: String {
        switch self {
        case .search: return "/v3/businesses/search"
        case .business(let id): return "/v3/businesses/\(id)"
        case .reviews(let id): return "/v3/businesses/\(id)/reviews"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let term, let coordinate, let radius, let categories, let limit, let sortBy):
            return [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "latitude", value: coordinate.latitude.description),
                URLQueryItem(name: "longitude", value: coordinate.longitude.description),
                URLQueryItem(name: "radius", value: radius?.description),
                URLQueryItem(name: "categories", value: categories.map({$0.alias}).joined(separator: ",")),
                URLQueryItem(name: "limit", value: limit?.description),
                URLQueryItem(name: "sort_by", value: sortBy?.description)
            ]
        case .business: return []
        case .reviews: return []
        }
    }
}
