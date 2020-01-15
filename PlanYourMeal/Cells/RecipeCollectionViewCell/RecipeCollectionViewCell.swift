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
    @IBOutlet weak var nameOfrecipe: UILabel!
    @IBOutlet weak var decorationView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.layer.cornerRadius = 20
        designDecorationView()
    }
    
    private func designDecorationView() {
        decorationView.layer.cornerRadius = 4
        decorationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        decorationView.layer.shadowColor = UIColor.green.cgColor
        decorationView.layer.shadowRadius = 25
        decorationView.layer.shadowOpacity = 0.7
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
        } else {
            self.image.image = nil
        }
    }
}
