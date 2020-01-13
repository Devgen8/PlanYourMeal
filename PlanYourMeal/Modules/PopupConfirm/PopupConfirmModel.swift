//
//  PopupConfirmModel.swift
//  PlanYourMeal
//
//  Created by мак on 12/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class PopupConfirmModel {
    func deleteUser() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).delete { (error) in
                guard error == nil else {
                    print("Error with deleting users data: ", error?.localizedDescription ?? "")
                    return
                }
            }
            Auth.auth().currentUser?.delete(completion: { (error) in
                guard error == nil else {
                    print("Error with deleting account: ", error?.localizedDescription ?? "")
                    return
                }
            })
        }
    }
}
