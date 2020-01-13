//
//  SignInModel.swift
//  PlanYourMeal
//
//  Created by мак on 11/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class SignInModel {
    var signInViewController: SignInViewController?
    
    init(with viewController: SignInViewController) {
        signInViewController = viewController
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, err) in
            guard let `self` = self else { return }
            if err != nil {
                self.signInViewController?.errorLabel.text = err?.localizedDescription
                self.signInViewController?.errorLabel.alpha = 1
            } else {
                let newVC = TabBarViewController()
                newVC.modalPresentationStyle = .fullScreen
                self.signInViewController?.present(newVC, animated: true, completion: nil)
            }
        }
    }
}
