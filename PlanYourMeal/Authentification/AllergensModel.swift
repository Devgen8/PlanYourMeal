//
//  AllergensModel.swift
//  PlanYourMeal
//
//  Created by мак on 06/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

//struct AllergensModel {
//
//    var usersAllergensInfo: [String]?
//    var dietType: String?
//
//    init () {
//        let db = Firestore.firestore()
//        let userId = Auth.auth().currentUser?.uid ?? ""
//        db.collection("/users/\(userId)/Additional info").document("Allergens").getDocument { (snapshot, error) in
//            if error != nil {
//                print(error?.localizedDescription ?? "Error: can not read data about allergens")
//            } else {
//                self?.usersAllergensInfo = snapshot?.data()?["allergens"] as? [String]
//                self?.dietType = snapshot?.data()?["dietType"] as? String
//            }
//            self?.allergensTableView.reloadData()
//        }
//    }
//}
