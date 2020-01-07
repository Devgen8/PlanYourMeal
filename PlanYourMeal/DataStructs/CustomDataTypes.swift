//
//  CustomDataTypes.swift
//  PlanYourMeal
//
//  Created by мак on 06/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation

struct MealDataModel {
    var name: String?
    var ingredientNames = [String]()
    var ingredientWeights = [Float]()
    var calories: Float?
    var image: String?
    var url: String?
}

struct ShoppingListItem {
    var name: String?
    var weight: Float?
    var bought = false
}

enum GlassActivityStatusPicker {
    case fill
    case empty
}
