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
    
    static var userAllergens = [String]()
    
    static  var usersDietType : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            AllergensTableViewCell.userAllergens = AllergensTableViewCell.userAllergens.filter({
                $0 != nameOfAllergen.text
                || $0 != "pecatarian"
                || $0 != "vegan"
                || $0 != "vegetarian"})
            
            for index in Diet.dietType.indices {
                if nameOfAllergen.text! == Diet.dietType[index] {
                    AllergensTableViewCell.usersDietType = Diet.dietType[index]
                }
            }
        } else {
            if (nameOfAllergen.text! != "pecatarian" ||
                nameOfAllergen.text! != "vegan" ||
                nameOfAllergen.text! != "vegetarian") {
                AllergensTableViewCell.userAllergens += [nameOfAllergen.text!]
            }
            if nameOfAllergen.text! == AllergensTableViewCell.usersDietType {
                AllergensTableViewCell.usersDietType = nil
            }
        }
    }
}
