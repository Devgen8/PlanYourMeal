//
//  AccountSettingsModel.swift
//  PlanYourMeal
//
//  Created by мак on 07/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class AccountSettingsModel {
    var delegate: DataReloaderDelegate?
    var email = Auth.auth().currentUser?.email
    let db = Firestore.firestore()
    var age: Int?
    var name: String?
    
    init(with reloaderDelegate: DataReloaderDelegate) {
        delegate = reloaderDelegate
    }
    
    func fillInFields() {
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("users").document(userId).getDocument { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                guard error == nil else {
                    print("Error reading data: \(error?.localizedDescription ?? "nil")")
                    return
                }
                self.age = snapshot?.data()?["age"] as? Int
                self.name = snapshot?.data()?["name"] as? String
                self.delegate?.reloadInfo?()
            }
        }
    }
    
    func updateUsersEmail(with newEmail: String) {
        if let user = Auth.auth().currentUser {
            db.collection("users").document(user.uid).updateData(["email" : newEmail]) { (error) in
                guard error == nil else {
                    print("Something went wrong with email changing...")
                    return
                }
            }
            user.updateEmail(to: newEmail, completion: { (error) in
                guard error == nil else {
                    print("Something went wrong with email changing...")
                    return
                }
            })
        }
    }
    
    func updateUsersName(with newName: String) {
        if let user = Auth.auth().currentUser {
            db.collection("users").document(user.uid).updateData(["name" : newName]) { (error) in
                guard error == nil else {
                    print("Something went wrong with name changing...")
                    return
                }
            }
        }
    }
    
    func updateUsersAge(with newAge: String) {
        if let user = Auth.auth().currentUser {
            db.collection("users").document(user.uid).updateData(["age" : Int(newAge) ?? 0]) { (error) in
                guard error == nil else {
                    print("Something went wrong with age changing...")
                    return
                }
            }
        }
    }
}
