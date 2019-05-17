//
//  SearchResultsController.swift
//  TestProject
//
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class SearchResultsController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    let priceLabels = ["Free", "$", "$$", "$$$", "$$$$"]
    var searchResults: [GooglePlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
    }
    
    
}


extension SearchResultsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultTableViewCell
        
        let place = self.searchResults[indexPath.row]
        //Sets the text boxes in each cell to each google Place information
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.address
        cell.priceLabel.text = place.priceLevel != nil ? self.priceLabels[place.priceLevel!] : "?"
        cell.ratingLabel.text = place.rating != nil ? String(place.rating!) : "(none)"
        cell.placeImageView.image = place.photo
        
        //Scales image size for clean icon
        cell.placeImageView.image = place.photo?.scaleImage(toSize: CGSize.init(width: 120.0, height: 120.0))
        
        //Border of cells
        cell.layer.borderColor = UIColor(red: 249.0/255.0, green: 156.0/255.0, blue: 8.0/255.0, alpha: 1.0).cgColor
        cell.layer.borderWidth = 0.7
        
        return cell
    }
    
}

//Extension to scale the title images received for each place from the Google Places API into the same 120X120 sizes to match as consistent icons
extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}
