//
//   Product.swift
//  XYZCommerce
//
//  Created by Lukas Tanto on 12/02/22.
//  Copyright © 2022 Lukas Tanto. All rights reserved.
//

import Foundation

struct Product: Codable{
    let product_id: Int
    let category: String
    let product_title: String
    let stock: Int
    let price: Int
    let image: String
    let reviews: [Review]
}
