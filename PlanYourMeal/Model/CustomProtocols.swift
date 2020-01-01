//
//  CustomProtocols.swift
//  PlanYourMeal
//
//  Created by мак on 07/12/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation

protocol DataReloaderDelegate {
    func reloadInfo()
}

protocol RecipeOpenerDelegate {
    func addMeal(_ recipe: Recipe?)
}

protocol AddingNewMealDelegate {
    func getInfoForNewMeal(image: UIImage, calories: String, name: String)
}

protocol IngredientStatusDelegate {
    func changeIngredientStatus(for item: ShoppingListItem, section: Int, row: Int)
}

protocol AllergensInfoChangerDelegate {
    func updateInfo(of allergen: String, to state: Bool)
}

protocol TapReciverDelegate {
    func handleTap(for index: Int)
}
