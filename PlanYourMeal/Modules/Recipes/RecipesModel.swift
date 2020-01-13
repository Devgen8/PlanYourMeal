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
}
