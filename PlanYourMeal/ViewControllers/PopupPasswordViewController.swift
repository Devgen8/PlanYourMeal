//
//  PopupPasswordViewController.swift
//  PlanYourMeal
//
//  Created by мак on 14/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth

class PopupPasswordViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var currentPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var newPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 25.0
        Design.styleTextField(currentPassTextField)
        Design.styleTextField(newPassTextField)
        Design.styleTextField(confirmPassTextField)
        Design.styleHollowButton(cancelButton)
        Design.styleHollowButton(okButton)
        errorLabel.isHidden = true
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
    }
    @IBAction func cancelTapped(_ sender: UIButton) {
        let presentingVC = presentingViewController as! AccountSettingsViewController
        presentingVC.blurView?.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        let presentingVC = presentingViewController as! AccountSettingsViewController
        guard currentPassTextField.text == Password.userPassword else {
            errorLabel.text = "Try again. Your current password is not right"
            errorLabel.isHidden = false
            return
        }
        guard newPassTextField.text == confirmPassTextField.text, newPassTextField.text != "" else {
            errorLabel.text = "Try again. Your new password don't match with confirmation"
            errorLabel.isHidden = false
            return
        }
        presentingVC.passwordButton.setTitle(newPassTextField.text, for: .normal)
        Password.userPassword = newPassTextField.text!
        var pass = ""
        for _ in Password.userPassword { pass += "•" }
        presentingVC.passwordButton.setTitle(pass, for: .normal)
        Auth.auth().currentUser?.updatePassword(to: Password.userPassword, completion: { (error) in
            guard error == nil else {
                presentingVC.showError("Something went wrong with password changing...")
                return
            }
        })
        presentingVC.blurView?.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
}
