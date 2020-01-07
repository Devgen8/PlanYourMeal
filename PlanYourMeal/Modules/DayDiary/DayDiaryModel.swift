//
//  DayDiaryModel.swift
//  PlanYourMeal
//
//  Created by мак on 07/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class DayDiaryModel {
    private var delegate: DataReloaderDelegate?
    var dayOffset = 0
    var weekday = ""
    var mealTypes: [String]?
    var recomendedCalories: [String]?
    var waterGlasses: Int?
    private let networkDataFetcher = NetworkDataFetcher()
    
    init(with reloaderDelegate: DataReloaderDelegate) {
        delegate = reloaderDelegate
    }
    
    func getDataFromDatabase() {
        getWeekdayMealTypes()
    }
    
    private func getWeekdayMealTypes() {
        weekday = getWeekdayName(with: dayOffset) ?? ""
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).getDocument { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read meal types info")
                    return
                }
                self.mealTypes = snapshot?.data()?["mealTypes"] as? [String]
                self.recomendedCalories = snapshot?.data()?["recomendedCalories"] as? [String]
                self.waterGlasses = snapshot?.data()?["waterGlassesNumber"] as? Int
                self.delegate?.reloadInfo?()
            }
        }
    }
    
    private func getWeekdayName(with offset: Int) -> String? {
        var weekdayName: String?
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekdayName = dateFormatter.string(from: date)
        }
        return weekdayName
    }
    
    func makeRecipesAutoPicking() {
        var indexOfMeal = 0
        for mealType in mealTypes ?? [] {
            print(mealType)
            let letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "v"]
            let randomLetter = letters[Int.random(in: 0..<letters.count)]
            let urlString = getUserRelatedUrlString(withText: randomLetter, calories: recomendedCalories?[indexOfMeal] ?? "")
            networkDataFetcher.fetchRecipes(urlString: urlString) { [weak self] (searchResponse) in
                guard searchResponse != nil else {
                    return
                }
                if let numberOfRecipes = searchResponse?.hits?.count, numberOfRecipes != 0 {
                    let randomNumber = Int.random(in: 0..<numberOfRecipes)
                    let randomRecipe = searchResponse?.hits?[randomNumber].recipe
                    if let recipe = randomRecipe {
                        if let userId = Auth.auth().currentUser?.uid {
                            var ingredientNames = [String]()
                            var ingredientWeights = [Float]()
                            var ingredientStatus = [Bool]()
                            for ingredient in (recipe.ingredients ?? [Ingredient()]) {
                                ingredientNames.append(ingredient.text ?? "")
                                ingredientWeights.append(ingredient.weight ?? 0)
                                ingredientStatus.append(false)
                            }
                            Firestore.firestore().collection("users").document(userId).collection("Meals").document(self?.weekday ?? "").collection("MealTypes").document("\(mealType)").setData([
                            "calories":(recipe.calories ?? 0)/10,
                            "image":recipe.image ?? "",
                            "ingredientNames":ingredientNames,
                            "ingredientWeights":ingredientWeights,
                            "ingredientStatus":ingredientStatus,
                            "name":recipe.label ?? "",
                            "mealType":mealType,
                            "url":recipe.url ?? ""])
                            indexOfMeal += 1
                            if indexOfMeal + 1 == mealType.count {
                                self?.delegate?.reloadInfo?()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUserRelatedUrlString(withText editedString: String, calories: String) -> String {
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
        let urlString = "https://api.edamam.com/search?q=\(editedString)&app_id=a5d31602&app_key=77acb77520745ac6c97ca539e8b612cb&calories=\(calories)\(healthParametersJoined ?? "&diet=balanced")"
        return urlString
    }
}
