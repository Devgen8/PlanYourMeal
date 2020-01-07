//
//  RecipesModel.swift
//  PlanYourMeal
//
//  Created by мак on 07/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation

class RecipesModel {
    var searchResponse: SearchResponse?
    
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
    
    func getUserRelatedUrlString(with editedString: String) -> String {
        var healthParameters: [String]?
        var healthParametersJoined: String?
        if let diet = User.dietType, diet != "" {
            healthParameters = [diet]
        }
        if let allergens = User.allergensInfo {
            healthParameters = healthParameters != nil ? healthParameters ?? [] + allergens : allergens
        }
        healthParametersJoined = healthParameters?.joined(separator: "&health=")
        if let joinedString = healthParametersJoined{
            healthParametersJoined = "&health=" + joinedString
        }
        let urlString = "https://api.edamam.com/search?q=\(editedString)&app_id=a5d31602&app_key=77acb77520745ac6c97ca539e8b612cb\(healthParametersJoined ?? "&diet=balanced")"
        return urlString
    }
}
