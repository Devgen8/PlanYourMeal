//
//  SignInViewController.swift
//  PlanYourMeal
//
//  Created by мак on 23/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    lazy var signInModel = SignInModel(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpOutlets()
    }
    
    private func setUpOutlets() {
        errorLabel.alpha = 0
        Design.styleTextField(emailTextField)
        Design.styleTextField(passwordTextField)
        Design.styleFilledButton(signInButton)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        if
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            signInModel.signIn(email: email, password: password)
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
