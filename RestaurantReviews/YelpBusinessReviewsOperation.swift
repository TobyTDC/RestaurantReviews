//
//  YelpBusinessReviewsOperation.swift
//  RestaurantReviews
//
//  Created by toby tang on 2017-12-17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

class YelpBusinessReviewsOperation: Operation {
    let business: YelpBusiness
    let client: YelpClient
    
    init(business: YelpBusiness, client: YelpClient) {
        self.business = business
        self.client = client
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _finished = false // backing variable
    override private(set) var isFinished: Bool { // make just the setter private
        get {
            return _finished
        }
        
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var _executing = false
    override private(set) var isExecuting: Bool {
        get {
            return _executing
        }
        
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        client.reviews(for: business) {
            result in
            switch result {
            case .success(let reviews):
                self.business.reviews = reviews
                self.isExecuting = false
                self.isFinished = true
            case .failure(let error):
                print(error)
                self.isExecuting = false
                self.isFinished = true
            }
        }
    }
}

