//
//  ViewController.swift
//  XYZCommerce
//
//  Created by Lukas Tanto on 09/02/22.
//  Copyright © 2022 Lukas Tanto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var stockLbl: UILabel!
    @IBOutlet var ratingLbl: UILabel!
    @IBOutlet var reviewerLbl: UILabel!
    @IBOutlet var commentLbl: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

