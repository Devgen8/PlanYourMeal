//
//  RecipeCollectionViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 17/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    //@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nameOfrecipe: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateAppearanceFor(_ image: UIImage?) {
        self.displayImage(image)
    }

    override func prepareForReuse() {
        image.image = nil
    }

    private func displayImage(_ image: UIImage?) {
        if let _ = image {
            self.image.image = image
            //loadingIndicator.stopAnimating()
            //loadingIndicator.isHidden = true
        } else {
            self.image.image = nil
            //loadingIndicator.startAnimating()
            //loadingIndicator.isHidden = false
        }
    }
}
