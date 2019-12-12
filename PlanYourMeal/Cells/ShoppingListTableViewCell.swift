//
//  ShoppingListTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 17/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredient: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var ingredientItem: ShoppingListItem?
    var delegate: IngredientStatusDelegate?
    var sectionIndex = 0
    var rowIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        if ingredientItem?.bought ?? false {
            checkButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        } else {
            checkButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        }
        if let item = ingredientItem {
            delegate?.changeIngredientStatus(for: item, section: sectionIndex, row: rowIndex)
        }
    }
}
