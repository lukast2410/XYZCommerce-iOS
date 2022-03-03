//
//  ExploreViewController.swift
//  XYZCommerce
//
//  Created by Lukas Tanto on 12/02/22.
//  Copyright © 2022 Lukas Tanto. All rights reserved.
//

import UIKit
import CoreData

struct APIResult: Codable{
    let status: String
    let results: [Product]
}

class ExploreViewController: UITableViewController{
    let baseUrl = "https://gz4ad4m977.execute-api.ap-southeast-1.amazonaws.com/get-products?keyword="
    let imageUrl = "https://thumbnails2022113.s3.ap-southeast-1.amazonaws.com/"
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var exploreTableView: UITableView!
    @IBOutlet var messageLbl: UILabel!
    var products = [Product]()
    var selectedIndex = -1
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        let recog = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        exploreTableView.addGestureRecognizer(recog)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "productViewCell", for: indexPath) as! ProductViewCell
        
        let product = products[indexPath.row]
        if(product.image != ""){
            
            let url = URL(string: imageUrl + products[indexPath.row].image)
            DispatchQueue.global().async {
                let imageData = try? Data(contentsOf: url!)
                if(imageData != nil){
                    DispatchQueue.main.async {
                        productCell.productImage.image = UIImage(data: imageData!)
                    }
                }
            }
        }
        productCell.nameLbl.text = product.product_title
        productCell.priceLbl.text = "Rp. \(product.price)"
        
        if(product.reviews.count == 0){
            productCell.ratingLbl.text = "-"
        }else{
            var totalRating = 0
            for x in product.reviews {
                totalRating += x.score
            }
            let average = Double(totalRating) / Double(product.reviews.count)
            productCell.ratingLbl.text = "\(average)"
        }	
        
        return productCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "exploreToDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if(sender.state == .began){
            let point = sender.location(in: exploreTableView)
            if let indexPath = exploreTableView.indexPathForRow(at: point) {
                handleSaveProduct(indexPath: indexPath)
            }
        }
    }
    
    func handleSaveProduct(indexPath: IndexPath){
        alert(msg: "Save to favorite?", handler: { (al) in
            let cell = self.exploreTableView.cellForRow(at: indexPath) as! ProductViewCell
            let product = self.products[indexPath.row]
            
            let request = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
            let predicate = NSPredicate(format: "product_id == %i", product.product_id)
            request.predicate = predicate
            
            do{
                let result = try self.context.fetch(request)
                
                if(result.count > 0){
                    self.alert(msg: "Product already in your favorite!", handler: nil, showCancel: false)
                    return
                }
            }catch{
            }
            
            
            let productEntity = ProductEntity(context: self.context)
            productEntity.product_id = Int16(product.product_id)
            productEntity.product_title = product.product_title
            productEntity.category = product.category
            productEntity.price = Int32(product.price)
            productEntity.stock = Int16(product.stock)
            productEntity.image = cell.productImage.image?.pngData()
            
            for rv in product.reviews {
                let review = ReviewEntity(context: self.context)
                review.username = rv.username
                review.score = Double(rv.score)
                review.comment = rv.comment ?? ""
                productEntity.addToReviews(review)
            }
            
            do{
                try self.context.save()
            }catch{
            }
            
            self.alert(msg: "Saved Successfully", handler: nil, showCancel: false)
            
        }, showCancel: true)
    }
    
    @IBAction func doSearch(_ sender: Any) {
        if(searchTF.text?.count ?? 0 < 3){
            messageLbl.text = "Keyword must be 3 charactes minimum"
            messageLbl.isHidden = false
            
            alert(msg: "Keyword must be 3 charactes minimum", handler: nil, showCancel: false)
            return
        }
        
        getDataBySearchKeyword(keyword: searchTF.text!)
    }
    
    func getDataBySearchKeyword(keyword: String){
        let url = URL(string: baseUrl + keyword)
        URLSession.shared.dataTask(with: url!){data, response, error in
            do{
                let res = try JSONDecoder().decode(APIResult.self, from: data!)
                
                self.products.removeAll()
                self.products.append(contentsOf: res.results)
                
                DispatchQueue.main.async {
                    self.refreshView()
                }
            }catch let error {
                print(error)
            }
        }.resume()
    }
    
    func refreshView(){
        if(products.count < 1){
            messageLbl.text = "No Product Found!"
            messageLbl.isHidden = false
        }else{
            messageLbl.isHidden = true
        }
        
        exploreTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "exploreToDetail" && selectedIndex >= 0){
            let dest = segue.destination as! ViewController
            dest.loadViewIfNeeded()
            let product = products[selectedIndex]
            let cell = exploreTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as! ProductViewCell
            
            if(product.image != "" && cell.productImage.image != nil){
                dest.productImage.image = cell.productImage.image
            }
            
            dest.titleLbl.text = "Title: \(product.product_title)"
            dest.priceLbl.text = "Price: \(product.price)"
            dest.stockLbl.text = "Stock: \(product.stock)"
            
            if(product.reviews.count == 0){
                dest.ratingLbl.text = "---"
                dest.reviewerLbl.text = "No review yet"
                dest.commentLbl.text = ""
            }else{
                var review = product.reviews[0]
                for x in product.reviews {
                    if(review.score < x.score){
                        review = x
                    }
                }
                
                dest.ratingLbl.text = "\(Double(review.score))"
                dest.reviewerLbl.text = "by \(review.username)"
                dest.commentLbl.text = review.comment ?? "No Comment"
            }
        }
    }
    
    func alert (msg: String, handler: ((UIAlertAction)->Void)?, showCancel: Bool){
        let alert = UIAlertController(title: "Alert", message: msg,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        let cancelAction  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        if(showCancel){
            alert.addAction(cancelAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
