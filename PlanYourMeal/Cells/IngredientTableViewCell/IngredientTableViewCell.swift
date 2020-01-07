//
//  IngredientTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 21/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var measure: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var nameOfIngredient: UILabel!
    @IBOutlet weak var decorationView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designDecorationView()
    }
    
    private func designDecorationView() {
        decorationView.layer.cornerRadius = 4
        decorationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        decorationView.layer.shadowColor = UIColor.green.cgColor
        decorationView.layer.shadowRadius = 8
        decorationView.layer.shadowOpacity = 0.7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
