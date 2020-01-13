//
//  SignUpModel.swift
//  PlanYourMeal
//
//  Created by мак on 11/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class SignUpModel {
    
    var signUpViewController: SignUpViewController?
    
    init(with viewController: SignUpViewController) {
        signUpViewController = viewController
    }
    
    func createNewUser(_ user: UserProfile) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { [weak self] (result, err) in
            guard let `self` = self else { return }
            if err != nil {
                self.signUpViewController?.showError(err?.localizedDescription ?? "Try again later, please")
            } else {
                let db = Firestore.firestore()
                if let registrationResult = result {
                    db.collection("users").document("\(registrationResult.user.uid)").setData(["name":user.name,
                                                                                               "age":user.age,
                                                                                               "email":user.email,
                                                                              "uid":registrationResult.user.uid,
                                                                              "password":user.password])
                    {(error) in
                        if error != nil {
                            self.signUpViewController?.showError("There are some problems with your internet connection. Try again later")
                        }
                    }
                }
            }
        }
    }
}
