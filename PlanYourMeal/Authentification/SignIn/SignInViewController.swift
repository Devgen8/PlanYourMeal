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
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, err) in
                guard let `self` = self else { return }
                if err != nil {
                    self.errorLabel.text = err?.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    let newVC = TabBarViewController()
                    newVC.modalPresentationStyle = .fullScreen
                    self.present(newVC, animated: true, completion: nil)
                }
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}