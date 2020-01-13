//
//  SignUpViewController.swift
//  PlanYourMeal
//
//  Created by мак on 23/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    lazy var signUpModel = SignUpModel(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpOutlets()
    }
    
    private func setUpOutlets() {
        errorLabel.alpha = 0
        Design.styleTextField(nameTextField)
        Design.styleTextField(ageTextField)
        Design.styleTextField(emailTextField)
        Design.styleTextField(passwordTextField)
        Design.styleFilledButton(signUpButton)
        nameTextField.delegate = self
        ageTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    //returns text of error in case of invalidable field
    private func validateFields() -> String? {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            email == "" ||
            password == "" {
            return "Please fill in all fields."
        }
        if !(email?.contains("@") ?? false && email?.contains(".") ?? false) {
            return "Please, use email format: example@gmail.com"
        }
        if password?.count ?? 0 < 8 {
            return "Password should be at least 8 symbols."
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let error = validateFields()
        if let errorDescription = error {
            showError(errorDescription)
        } else {
            if
                let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let age = Int(ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""),
                let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let userProfile = UserProfile(name: name, age: age, email: email, password: password)
                signUpModel.createNewUser(userProfile)
            }
            let newVC = UserGoalViewController()
            newVC.modalPresentationStyle = .fullScreen
            present(newVC, animated: true, completion: nil)
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}

// MARK: UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
