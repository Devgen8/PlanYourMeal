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
            let letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "v"]
            let randomLetter = letters[Int.random(in: 0..<letters.count)]
            let urlString = NetworkingService.getUserRelatedUrlString(with: randomLetter)
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
                            if (indexOfMeal + 1) == self?.mealTypes?.count {
                                self?.delegate?.reloadInfo?()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getMeals(completion: @escaping (_ calories: Int?, _ meals: [Int:MealDataModel]?) -> Void) {
        var totalCalories = 0
        var meals = [Int:MealDataModel]()
        if let userId = Auth.auth().currentUser?.uid { Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error: can not read meals info")
                } else {
                    guard snapshot != nil else { return }
                    guard let `self` = self else { return }
                    var documentNumber = 0
                    for document in snapshot!.documents {
                        var indexOfMeal = 0
                        if let documentMealType = document.data()["mealType"] as? String,
                            let modelMealTypes = self.mealTypes {
                            for mealType in modelMealTypes {
                                if documentMealType == mealType {
                                    break
                                }
                                indexOfMeal += 1
                            }
                        } else {
                            completion(nil, nil)
                            return
                        }
                        var meal = MealDataModel()
                        meal.name = document.data()["name"] as? String
                        meal.calories = document.data()["calories"] as? Float
                        meal.image = document.data()["image"] as? String
                        if let ingredients = document.data()["ingredientNames"] as? [String] {
                            meal.ingredientNames = ingredients
                        }
                        if let weights = document.data()["ingredientWeights"] as? [Float] {
                            meal.ingredientWeights = weights
                        }
                        meal.url = document.data()["url"] as? String
                        totalCalories += Int(meal.calories ?? 0)
                        documentNumber += 1
                        meals[indexOfMeal] = meal
                        if documentNumber == snapshot?.documents.count {
                            completion(totalCalories, meals)
                        }
                    }
                }
            }
        }
    }
    
    func getPhoto(with url: URL?, completion: @escaping ((_ photo: UIImage?) -> Void)) {
        guard url != nil else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
                else {
                    completion(nil)
                    return
            }
            completion(UIImage(data: data))
        }.resume()
    }
    
    func updateMealTypes() {
        if let userId = Auth.auth().currentUser?.uid, let types = mealTypes, let calories = recomendedCalories {
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).updateData(["mealTypes":types,                                                                                   "recomendedCalories":calories])
        }
    }
        
    func deleteMealType(_ type: String) {
       if let userId = Auth.auth().currentUser?.uid { Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").document(type).delete()
        }
        mealTypes = mealTypes?.filter {$0 != type}
    }
}
