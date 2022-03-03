//
//  ProductViewCell.swift
//  XYZCommerce
//
//  Created by Lukas Tanto on 12/02/22.
//  Copyright © 2022 Lukas Tanto. All rights reserved.
//

import UIKit

class ProductViewCell: UITableViewCell {
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var ratingLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        container.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }

}
