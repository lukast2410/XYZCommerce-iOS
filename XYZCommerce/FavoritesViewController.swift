//
//  FavoritesViewController.swift
//  XYZCommerce
//
//  Created by Lukas Tanto on 12/02/22.
//  Copyright © 2022 Lukas Tanto. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UITableViewController {
    @IBOutlet var favoritesTableView: UITableView!
    @IBOutlet var messageLbl: UILabel!
    
    var products = [ProductEntity]()
    var selectedIndex = -1
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        let recog = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        favoritesTableView.addGestureRecognizer(recog)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        products.removeAll()
        
        let request = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
        
        do{
            let result = try context.fetch(request)
            
            products.append(contentsOf: result)
            
            favoritesTableView.reloadData()
            
            if(products.count == 0){
                messageLbl.text = "Favorite is empty"
            }else{
                messageLbl.text = ""
            }
        }catch{
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "productViewCell", for: indexPath) as! ProductViewCell
        
        let product = products[indexPath.row]
        if(product.image != nil){
            productCell.productImage.image = UIImage(data: product.image!)
        }
        productCell.nameLbl.text = product.product_title
        productCell.priceLbl.text = "Rp. \(product.price)"
        
        let reviews = product.reviews?.allObjects as! [ReviewEntity]
        if(reviews.count == 0){
            productCell.ratingLbl.text = "-"
        }else{
            var totalRating = 0.0
            for x in reviews {
                totalRating += x.score
            }
            let average = Double(totalRating) / Double(reviews.count)
            productCell.ratingLbl.text = "\(average)"
        }
        
        return productCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "favoriteToDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if(sender.state == .began){
            let point = sender.location(in: favoritesTableView)
            if let indexPath = favoritesTableView.indexPathForRow(at: point) {
                handleDeleteProduct(indexPath: indexPath)
            }
        }
    }
    
    func handleDeleteProduct(indexPath: IndexPath){
        alert(msg: "Are you sure you want to delete?", handler: { (al) in
            let product = self.products[indexPath.row]
            
            do{
                self.context.delete(product)
                
                try self.context.save()
                
                self.products.remove(at: indexPath.row)
                self.favoritesTableView.beginUpdates()
                self.favoritesTableView.deleteRows(at: [indexPath], with: .middle)
                self.favoritesTableView.endUpdates()
                
                if(self.products.count == 0){
                    self.messageLbl.text = "Favorite is empty"
                }else{
                    self.messageLbl.text = ""
                }
            }catch{
                
            }
        }, showCancel: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "favoriteToDetail" && selectedIndex >= 0){
            let dest = segue.destination as! ViewController
            dest.loadViewIfNeeded()
            let product = products[selectedIndex]
            
            if(product.image != nil){
                dest.productImage.image = UIImage(data: product.image!)
            }
            
            dest.titleLbl.text = "Title: \(product.product_title!)"
            dest.priceLbl.text = "Price: \(product.price)"
            dest.stockLbl.text = "Stock: \(product.stock)"
            
            let reviews = product.reviews?.allObjects as! [ReviewEntity]
            if(reviews.count == 0){
                dest.ratingLbl.text = "---"
                dest.reviewerLbl.text = "No review yet"
                dest.commentLbl.text = ""
            }else{
                var review = reviews[0]
                for x in reviews {
                    if(review.score < x.score){
                        review = x
                    }
                }
                
                dest.ratingLbl.text = "\(Double(review.score))"
                dest.reviewerLbl.text = "by \(review.username!)"
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
