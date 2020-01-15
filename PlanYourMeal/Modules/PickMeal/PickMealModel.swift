//
//  PickMealModel.swift
//  PlanYourMeal
//
//  Created by мак on 07/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class PickMealModel {
    var delegate: DataReloaderDelegate?
    var searchResponse: SearchResponse?
    var weekday: String?
    var mealType: String?
    
    init(with reloaderDelegate: DataReloaderDelegate) {
        delegate = reloaderDelegate
    }
    
    private func downloadImageFromURL(_ url: URL?, at index: Int) {
        guard url != nil else { return }
        URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let newImage = UIImage(data: data)
                else { return }
            self?.delegate?.updateImageView?(with: newImage, for: index)
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
    
    func addMealToDatabase(_ recipe: Recipe) {
        var ingredientNames = [String]()
        var ingredientWeights = [Float]()
        if let userIngredients = recipe.ingredients {
            for ingredient in userIngredients {
                ingredientNames.append(ingredient.text ?? "")
                ingredientWeights.append(ingredient.weight ?? 0)
            }
        }
        if let userId = Auth.auth().currentUser?.uid {
            let mealCalories = (recipe.calories ?? 0.0)
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday ?? "").collection("MealTypes").document(mealType ?? "").setData([
                "image":recipe.image ?? "",
                "name":recipe.label ?? "",
                "calories":mealCalories / 3,
                "mealType":mealType ?? "",
                "ingredientNames":ingredientNames,
                "ingredientWeights":ingredientWeights,
                "url":recipe.url ?? ""])
        }
    }
    
    func getIngredientNames(for index: Int) -> ([String], [Float]) {
        var names = [String]()
        var weights = [Float]()
        if let ingredients = searchResponse?.hits?[index].recipe?.ingredients {
            for ingredient in ingredients {
                names += [ingredient.text ?? ""]
                weights += [ingredient.weight ?? 0]
            }
        }
        return (names, weights)
    }
}
