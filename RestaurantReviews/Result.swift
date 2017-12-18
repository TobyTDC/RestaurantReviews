//
//  Result.swift
//  RestaurantReviews
//
//  Created by toby tang on 2017-12-17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

enum Result<T, U> where U: Error {
    case success(T)
    case failure(U)
}





