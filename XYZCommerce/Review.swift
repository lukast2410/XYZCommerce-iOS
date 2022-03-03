//
//  Review.swift
//  XYZCommerce
//
//  Created by Lukas Tanto on 12/02/22.
//  Copyright © 2022 Lukas Tanto. All rights reserved.
//

import Foundation

struct Review: Codable{
    let username: String
    let score: Int
    let comment: String?
}
