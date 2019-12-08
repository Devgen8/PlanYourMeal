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
    
    var recipeFromCollectionView: Recipe?
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredintsTableView.dataSource = self
        recipeName.text = recipeFromCollectionView?.label
        recipePhoto.image = image
        let firstNumber = (recipeFromCollectionView?.calories)!
        let secondNumber = (recipeFromCollectionView?.totalWeight)!
        caloriesLabel.text = "Calories: \(Int(firstNumber/secondNumber * 100))"
    }
    
    @IBAction func recipeButtonClicked(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: recipeFromCollectionView?.url ?? "")!,
                                  options: [:],
                                  completionHandler: nil)
    }
}

extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeFromCollectionView?.ingredients?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("IngredientTableViewCell", owner: self, options: nil)?.first as! IngredientTableViewCell
        
        cell.nameOfIngredient.text = recipeFromCollectionView?.ingredients?[indexPath.row].text
        cell.quantity.text = "\(Int(recipeFromCollectionView?.ingredients?[indexPath.row].weight ?? 1))"
        cell.measure.text = "g"
        return cell
    }
}
