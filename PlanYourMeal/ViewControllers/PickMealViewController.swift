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
    
    let networkDataFetcher = NetworkDataFetcher()
    var searchResponse: SearchResponse? = nil
    private var timer: Timer?
    let searchController = UISearchController(searchResultsController: nil)
    var recipeImages = [Int:UIImage]()
    var weekday: String?
    var mealType: String?
    var delegate: DataReloaderDelegate?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView.delegate = self
        mealsTableView.dataSource = self
        
        loadingIndicator.hidesWhenStopped = true
        searchBar.delegate = self
    }
    
    func downloadImageFromURL(_ url: URL?, at index: Int) {
        guard url != nil else { return }
        URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let newImage = UIImage(data: data)
                else { return }
            self?.recipeImages[index] = newImage
        }.resume()
    }
    
    func prepareRecipeImages() {
        if let recipes = searchResponse?.hits {
            var indexOfRecipe = 0
            for recipe in recipes {
                downloadImageFromURL(URL(string: recipe.recipe?.image ?? ""), at: indexOfRecipe)
                indexOfRecipe += 1
            }
        }
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
        cell.caloriesLabel.text = "\(Int(recipeForCell?.calories ?? 0)) kcal"
        cell.weightLabel.text = "\(Int(recipeForCell?.totalWeight ?? 0)) g"
        cell.recipe = recipeForCell
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension PickMealViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PickMealTableViewCell
        let destinationViewController = RecipeDetailViewController()
        destinationViewController.recipeFromCollectionView = cell?.recipe
        destinationViewController.image = recipeImages[indexPath.row] != nil ? recipeImages[indexPath.row] : #imageLiteral(resourceName: "recipe")
        present(destinationViewController, animated: true, completion: nil)
    }
}

extension PickMealViewController: RecipeOpenerDelegate {
    func addMeal(_ recipe: Recipe?) {
        if recipe != nil {
            var mealTypeWithOutIndex = ""
            if mealType != nil {
                mealTypeWithOutIndex = mealType!.components(separatedBy: CharacterSet.decimalDigits).joined()
            }
            var ingredientNames = [String]()
            var ingredientWeights = [Float]()
            if let userIngredients = recipe?.ingredients {
                for ingredient in userIngredients {
                    ingredientNames.append(ingredient.text ?? "")
                    ingredientWeights.append(ingredient.weight ?? 0)
                }
            }
            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday ?? "Monday").collection("MealTypes").document(mealType ?? "Lunch").setData([
                    "image":recipe!.image!,
                    "name":recipe!.label!,
                    "calories":recipe!.calories!,
                    "mealType":mealTypeWithOutIndex,
                    "ingredientNames":ingredientNames,
                    "ingredientWeights":ingredientWeights,
                    "documentName":mealType ?? "Lunch"])
            }
        }
        delegate?.reloadInfo()
        dismiss(animated: true, completion: nil)
    }
}

extension PickMealViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        self.mealsTableView.isHidden = true
        let urlString = "https://api.edamam.com/search?q=\(searchText)&app_id=a5d31602&app_key=77acb77520745ac6c97ca539e8b612cb"
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkDataFetcher.fetchRecipes(urlString: urlString) { [weak self] (searchResponse) in
                guard let searchResponse = searchResponse else { return }
                self?.searchResponse = searchResponse
                self?.prepareRecipeImages()
                self?.mealsTableView.isHidden = true
                self?.loadingIndicator.isHidden = false
                self?.loadingIndicator.startAnimating()
                self?.mealsTableView.reloadData()
                self?.mealsTableView.isHidden = false
            }
        })
        
        if searchText == "" {
            loadingIndicator.stopAnimating()
            mealsTableView.isHidden = true
        }
    }
}
