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
    @IBAction func touchedButton(_ sender: UIButton) {
        sender.setTitle((sender.titleLabel?.text == "✔️" ? "❌" : "✔️"), for: .normal)
//        if sender.titleLabel?.text == "✔️" {
//            sender.setTitle("❌", for: .normal)
//        } else {
//            sender.setTitle("✔️", for: .normal)
//        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
