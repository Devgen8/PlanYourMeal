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
    
    var recipe: MealDataModel?
    var cellIndex: Int?
    var delegate: TapReciverDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designDecorationView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func designDecorationView() {
        mealImageView.layer.cornerRadius = 25
        decorationView.layer.cornerRadius = 25
        decorationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        decorationView.layer.shadowColor = UIColor.green.cgColor
        decorationView.layer.shadowRadius = 8
        decorationView.layer.shadowOpacity = 0.7
    }
    
    @IBAction func addMealTapped(_ sender: UIButton) {
        if let index = cellIndex {
            delegate?.handleTap(for: index)
        }
    }
}
