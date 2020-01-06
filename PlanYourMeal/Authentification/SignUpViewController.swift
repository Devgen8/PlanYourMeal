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
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
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
                let age = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, err) in
                    guard let `self` = self else { return }
                    if err != nil {
                        self.showError(err?.localizedDescription ?? "Try again later, please")
                    } else {
                        let db = Firestore.firestore()
                        if let registrationResult = result {
                            db.collection("users").document("\(registrationResult.user.uid)").setData(["name":name,
                                                                                                       "age":Int(age) ?? 0,
                                                                                                       "email":email,
                                                                                                       "uid":registrationResult.user.uid]) {(error) in
                                                                                                        if error != nil {
                                                                                                            self.showError("There are some problems with your internet connection. Try again later")
                                                                                                        }
                            }
                        }
                    }
                }
            }
        }
        let newVC = UserGoalViewController()
        newVC.modalPresentationStyle = .fullScreen
        present(newVC, animated: true, completion: nil)
    }
    
    private func showError(_ message: String) {
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
