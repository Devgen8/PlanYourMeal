//
//  PickMealTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 07/12/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class PickMealTableViewCell: UITableViewCell {

    
    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    var recipe: Recipe?
    var delegate: RecipeOpenerDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addMealTapped(_ sender: UIButton) {
        delegate?.addMeal(recipe)
    }
    
}
