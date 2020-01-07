//
//  ShoppingListModel.swift
//  PlanYourMeal
//
//  Created by мак on 07/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class ShoppingListModel {
    var weekday = ""
    var mealTypes = [String]()
    var shoppingItemsStatus = [Int:[Bool]]()
    var userShoppingItems = [Int:[ShoppingListItem]]()
    var delegate: DataReloaderDelegate?
    
   func setUpTodayWeekday() {
        if let date = Calendar.current.date(byAdding: .day, value: 0, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekday = dateFormatter.string(from: date)
        }
    }
    
    init(with reloaderDelegate: DataReloaderDelegate) {
        delegate = reloaderDelegate
        setUpTodayWeekday()
    }
    
    func getMealTypes() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("Meals").document(weekday).getDocument { [weak self] (snapshot, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error: can not read meal types")
                return
            }
            if let meals = snapshot?.data()?["mealTypes"] as? [String] {
                self?.mealTypes = meals
            }
            self?.getUserShoppingItems()
        }
    }
    
    func getUserShoppingItems() {
        shoppingItemsStatus = [Int:[Bool]]()
        userShoppingItems = [Int:[ShoppingListItem]]()
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("Meals").document(weekday).collection("MealTypes").getDocuments { [weak self] (snapshot, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error: can not read meal types documents")
                return
            }
            if let docs = snapshot?.documents {
                guard let `self` = self else { return }
                for document in docs {
                    var indexOfDocument = 0
                    let documentMealType = document.data()["mealType"] as? String
                    for mealType in self.mealTypes {
                        if documentMealType == mealType {
                            break
                        }
                        indexOfDocument += 1
                    }
                    var shoppingListItemsForMeal = [ShoppingListItem]()
                    let ingredientNames = document.data()["ingredientNames"] as? [String]
                    let ingredientWeights = document.data()["ingredientWeights"] as? [Float]
                    let ingredientStatus = document.data()["ingredientStatus"] as? [Bool]
                    if let ingredients = ingredientNames {
                        var indexOfIngredient = 0
                        self.shoppingItemsStatus[indexOfDocument] = []
                        for ingredientName in ingredients {
                            var shoppingListItem = ShoppingListItem()
                            shoppingListItem.name = ingredientName
                            shoppingListItem.weight = ingredientWeights?[indexOfIngredient]
                            shoppingListItem.bought = ingredientStatus?[indexOfIngredient] ?? false
                            shoppingListItemsForMeal.append(shoppingListItem)
                            indexOfIngredient += 1
                            self.shoppingItemsStatus[indexOfDocument]?.append(shoppingListItem.bought)
                        }
                    }
                    self.userShoppingItems[indexOfDocument] = shoppingListItemsForMeal
                }
            }
            self?.delegate?.reloadInfo?()
        }
    }
    
    func getWeekdayName(with offset: Int) -> String? {
        var weekdayName: String?
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekdayName = dateFormatter.string(from: date)
        }
        return weekdayName
    }
}

extension ShoppingListModel: IngredientStatusDelegate {
    func changeIngredientStatus(for item: ShoppingListItem, section: Int, row: Int) {
        if let boughtStatus = userShoppingItems[section]?[row].bought {
            userShoppingItems[section]?[row].bought = !boughtStatus
            shoppingItemsStatus[section]?[row] = !boughtStatus
            if let itemsForSectionStatus = shoppingItemsStatus[section] {
                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("Meals").document(weekday).collection("MealTypes").document(mealTypes[section]).updateData(["ingredientStatus":itemsForSectionStatus])
            }
            delegate?.reloadInfo?()
        }
    }
}
