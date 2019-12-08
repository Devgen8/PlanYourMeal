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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
