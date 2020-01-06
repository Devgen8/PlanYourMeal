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
    @IBOutlet weak var decorationView: UIView!
    
    var ingredientItem: ShoppingListItem?
    var delegate: IngredientStatusDelegate?
    var sectionIndex = 0
    var rowIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designDecorationView()
    }
    
    func designDecorationView() {
        decorationView.layer.cornerRadius = 25
        decorationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        decorationView.layer.shadowColor = decorationView.backgroundColor?.cgColor
        decorationView.layer.shadowRadius = 8
        decorationView.layer.shadowOpacity = 0.7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        if ingredientItem?.bought ?? false {
            checkButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
            decorationView.backgroundColor = .systemRed
            decorationView.layer.shadowColor = UIColor.systemRed.cgColor
        } else {
            checkButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            decorationView.backgroundColor = .systemGreen
            decorationView.layer.shadowColor = UIColor.systemGreen.cgColor
        }
        if let item = ingredientItem {
            delegate?.changeIngredientStatus(for: item, section: sectionIndex, row: rowIndex)
        }
    }
}
