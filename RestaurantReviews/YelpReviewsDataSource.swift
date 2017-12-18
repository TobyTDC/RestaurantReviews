//
//  YelpReviewsDataSource.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation
import UIKit

class YelpReviewsDataSource: NSObject, UITableViewDataSource {
    private var data: [YelpReview]
    
    init(data: [YelpReview]) {
        self.data = data
        super.init()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseIdentifier, for: indexPath) as! ReviewCell
        
        let review = object(at: indexPath)
        let viewModel = ReviewCellViewModel(review: review)
        
        cell.configure(with: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reviews"
    }
    
    // MARK: Helpers
    
    func update(_ object: YelpReview, at indexPath: IndexPath) {
        data[indexPath.row] = object
    }
    
    func updateData(_ data: [YelpReview]) {
        self.data = data
    }
    
    func object(at indexPath: IndexPath) -> YelpReview {
        return data[indexPath.row]
    }
}
