//
//  AllergensTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 27/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class AllergensTableViewCell: UITableViewCell {

    @IBOutlet weak var allergenSwitcher: UISwitch!
    @IBOutlet weak var nameOfAllergen: UILabel!
    var delegate: AllergensInfoChangerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        if let allergenName = nameOfAllergen.text {
            delegate?.updateInfo(of: allergenName, to: allergenSwitcher.isOn)
        }
    }
}
