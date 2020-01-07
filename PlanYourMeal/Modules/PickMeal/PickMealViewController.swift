//
//  PickMealViewController.swift
//  PlanYourMeal
//
//  Created by мак on 07/12/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PickMealViewController: UIViewController {
    
    private let networkDataFetcher = NetworkDataFetcher()
    private var searchResponse: SearchResponse? = nil
    private var timer: Timer?
    private let searchController = UISearchController(searchResultsController: nil)
    private var recipeImages = [Int:UIImage]()
    var delegate: DataReloaderDelegate?
    lazy var pickMealModel = PickMealModel(with: self)
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hintLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView.delegate = self
        mealsTableView.dataSource = self
        
        loadingIndicator.hidesWhenStopped = true
        searchBar.delegate = self
    }
}

extension PickMealViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResponse?.hits?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("PickMealTableViewCell", owner: self, options: nil)?.first as! PickMealTableViewCell
        
        let recipeForCell = searchResponse?.hits?[indexPath.row].recipe
        
        cell.mealLabel.text = recipeForCell?.label ?? ""
        cell.caloriesLabel.text = "\(Int(recipeForCell?.calories ?? 0) / 10) kcal"
        cell.weightLabel.text = "\(Int(recipeForCell?.totalWeight ?? 0) / 10) g"
        cell.recipe = recipeForCell
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension PickMealViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PickMealTableViewCell
        let destinationViewController = RecipeDetailViewController()
        if let selectedRecipe = cell?.recipe {
            var recipeForDestVC = MealDataModel(name: selectedRecipe.label, calories: (selectedRecipe.calories ?? 0) / 10, url: selectedRecipe.url)
            let (ingredientNames, ingredientWeights) = pickMealModel.getIngredientNames(for: indexPath.row)
            recipeForDestVC.ingredientNames = ingredientNames
            recipeForDestVC.ingredientWeights = ingredientWeights
            destinationViewController.recipeFromParent = recipeForDestVC
        }
        destinationViewController.image = recipeImages[indexPath.row] != nil ? recipeImages[indexPath.row] : #imageLiteral(resourceName: "recipe")
        present(destinationViewController, animated: true, completion: nil)
    }
}

extension PickMealViewController: RecipeOpenerDelegate {
    func addMeal(_ newRecipe: Recipe?) {
        if let recipe = newRecipe {
            pickMealModel.addMealToDatabase(recipe)
            delegate?.makeRequestForData?()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension PickMealViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadingIndicator.startAnimating()
        mealsTableView.isHidden = true
        hintLabel.isHidden = true
        let editedString = searchText.replacingOccurrences(of: " ", with: "%20")
        let urlString = pickMealModel.getUserRelatedUrlString(with: editedString)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkDataFetcher.fetchRecipes(urlString: urlString) { [weak self] (searchResponse) in
                guard let searchResponse = searchResponse else { return }
                self?.searchResponse = searchResponse
                self?.pickMealModel.searchResponse = searchResponse
                self?.pickMealModel.prepareRecipeImages()
                self?.mealsTableView.isHidden = true
                self?.loadingIndicator.stopAnimating()
                self?.mealsTableView.reloadData()
                self?.mealsTableView.isHidden = false
                self?.hintLabel.isHidden = true
            }
        })
        
        if searchText == "" {
            loadingIndicator.stopAnimating()
            mealsTableView.isHidden = true
            hintLabel.isHidden = false
        }
    }
}

extension PickMealViewController: DataReloaderDelegate {
    func updateImageView(with image: UIImage, for index: Int) {
        recipeImages[index] = image
    }
}
