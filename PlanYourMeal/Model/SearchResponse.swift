//
//  SearchResponse.swift
//  PlanYourMeal
//
//  Created by мак on 20/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
    var count: Int?
    var hits: [Hit]?
}

struct Hit: Decodable {
    var recipe: Recipe?
}

struct Recipe: Decodable {
    var label: String?
    var image: String?
    var url: String?
    var calories: Float?
    var totalWeight: Float?
    var ingredients: [Ingredient]?
}

struct Ingredient: Decodable {
    var text: String?
    var quantity: Float?
    var measure: String?
    var food: String?
}
