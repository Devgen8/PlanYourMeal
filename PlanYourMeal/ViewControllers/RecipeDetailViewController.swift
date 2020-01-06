//
//  RecipeDetailViewController.swift
//  PlanYourMeal
//
//  Created by мак on 21/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var recipeName: UILabel!
    
    @IBOutlet weak var recipePhoto: UIImageView!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var ingredintsTableView: UITableView!
    @IBOutlet weak var fullRecipeButton: UIButton!
    
    var recipeFromParent: MealDataModel?
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredintsTableView.dataSource = self
        ingredintsTableView.delegate = self
        Design.styleFilledButton(fullRecipeButton)
        recipeName.text = recipeFromParent?.name
        recipePhoto.image = image
        if let calories = recipeFromParent?.calories {
            caloriesLabel.text = "Calories: \(Int(calories))"
        }
    }
    
    @IBAction func recipeButtonClicked(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: recipeFromParent?.url ?? "")!,
                                  options: [:],
                                  completionHandler: nil)
    }
}

extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeFromParent?.ingredientNames.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("IngredientTableViewCell", owner: self, options: nil)?.first as! IngredientTableViewCell
        
        cell.nameOfIngredient.text = recipeFromParent?.ingredientNames[indexPath.row]
        cell.quantity.text = "\(Int(recipeFromParent?.ingredientWeights[indexPath.row] ?? 1))"
        cell.measure.text = "g"
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
