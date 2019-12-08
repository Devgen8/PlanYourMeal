//
//  MealTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 01/12/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var mealTypeLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var mealImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        designDecorationView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func designDecorationView() {
        decorationView.layer.cornerRadius = 4
        decorationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        decorationView.layer.shadowColor = UIColor.green.cgColor
        decorationView.layer.shadowRadius = 8
        decorationView.layer.shadowOpacity = 0.7
    }
    
}
