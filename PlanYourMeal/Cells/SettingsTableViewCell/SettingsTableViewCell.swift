//
//  SettingsTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 06/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var decorationView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        decorationView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
