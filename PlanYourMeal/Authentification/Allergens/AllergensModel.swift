//
//  AllergensModel.swift
//  PlanYourMeal
//
//  Created by мак on 06/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class AllergensModel {

    private(set) var usersAllergensInfo: [String]?
    private(set) var dietType: String?
    private var delegate: DataReloaderDelegate?

    init (with reloaderDelegate: DataReloaderDelegate) {
        delegate = reloaderDelegate
        getDataFromDatabase()
    }
    
    func getDataFromDatabase() {
        let db = Firestore.firestore()
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("/users/\(userId)/Additional info").document("Allergens").getDocument { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read data about allergens")
                    return
                }
                self.usersAllergensInfo = snapshot?.data()?["allergens"] as? [String]
                self.dietType = snapshot?.data()?["dietType"] as? String
                self.delegate?.reloadInfo?()
            }
        }
    }
    
    func deliverDataToDatabase() {
        let db = Firestore.firestore()
        if let userId = Auth.auth().currentUser?.uid {
        db.collection("/users/\(userId)/Additional info").document("Allergens").setData([
            "allergens":usersAllergensInfo ?? [String](),
            "dietType":dietType ?? ""])
        }
    }
    
    func createMealSchedule() {
        if let userId = Auth.auth().currentUser?.uid {
            let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
            let recomendedCalories = ["500-600", "600-700", "500-600", "150"]
            for weekday in weekdays {
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).setData(["mealTypes":mealTypes,"recomendedCalories":recomendedCalories, "waterGlassesNumber":0])
                for mealType in mealTypes {
                    Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").document(mealType).setData(["mealType":mealType])
                }
            }
        }
    }
}

// MARK: AllergensInfoChangerDelegate
extension AllergensModel: AllergensInfoChangerDelegate {
    func updateInfo(of allergen: String, to state: Bool) {
        if state {
            if Diet.dietType.contains(allergen) {
                dietType = allergen
            } else {
                if usersAllergensInfo == nil {
                    usersAllergensInfo = [allergen]
                } else {
                    usersAllergensInfo! += [allergen]
                }
            }
        } else {
            if allergen == dietType {
                dietType = nil
            } else {
                usersAllergensInfo = usersAllergensInfo?.filter({ $0 != allergen })
                if usersAllergensInfo?.count == 0 {
                    usersAllergensInfo = nil
                }
            }
        }
        delegate?.reloadInfo?()
    }
}
