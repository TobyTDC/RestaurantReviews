//
//  ReviewCellViewModel.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation
import UIKit

struct ReviewCellViewModel {
    let review: String
    let userImage: UIImage
}

extension ReviewCellViewModel {
    init(review: YelpReview) {
        self.review = review.text
        self.userImage = review.user.image ?? #imageLiteral(resourceName: "Placeholder")
    }
}
