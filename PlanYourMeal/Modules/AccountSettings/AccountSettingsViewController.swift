//
//  AccountSettingsViewController.swift
//  PlanYourMeal
//
//  Created by мак on 12/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountSettingsViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var deleteAccButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    var blurView: UIVisualEffectView?
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    lazy var accountSettingsModel = AccountSettingsModel(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        ageTextField.delegate = self
        accountSettingsModel.fillInFields()
        setUpOutlets()
    }
    
    private func setUpOutlets() {
        errorLabel.alpha = 0
        Design.styleTextField(nameTextField)
        Design.styleTextField(ageTextField)
        Design.styleTextField(emailTextField)
        Design.styleFilledButton(okButton)
        Design.styleFilledButton(deleteAccButton)
        Design.styleFilledButton(logOutButton)
        passwordButtonDesign()
    }
    
    private func passwordButtonDesign() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: passwordButton.frame.height - 2, width: passwordButton.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        passwordButton.layer.addSublayer(bottomLine)
        passwordButton.titleLabel?.textAlignment = .left
        var pass = ""
        for _ in User.password { pass += "•" }
        passwordButton.setTitle(pass, for: .normal)
    }
    
    @IBAction func emailEditingFinished(_ sender: UITextField) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        accountSettingsModel.updateUsersEmail(with: email)
    }
    @IBAction func nameEditingFinished(_ sender: UITextField) {
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        accountSettingsModel.updateUsersName(with: name)
    }
    @IBAction func ageEditingFinished(_ sender: UITextField) {
        let age = ageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        accountSettingsModel.updateUsersAge(with: age)
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAccTapped(_ sender: UIButton) {
        makeBackgroundBlur()
        let modalViewController = PopupConfirmViewController()
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func passwordButtonTapped(_ sender: UIButton) {
        makeBackgroundBlur()
        let modalViewController = PopupPasswordViewController()
        modalViewController.newPassword = passwordButton.titleLabel?.text
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        let signOutAction = UIAlertAction(title: "Sign In", style: .destructive) { [weak self] (action) in
            do {
                try Auth.auth().signOut()
            } catch let error {
                print(error.localizedDescription)
            }
            guard let `self` = self else { return }
            let newVc = SignInViewController()
            newVc.modalPresentationStyle = .fullScreen
            self.present(newVc, animated: true, completion: nil)
        }
        let signInAction = UIAlertAction(title: "Sign Up", style: .destructive) { [weak self] (action) in
            do {
                try Auth.auth().signOut()
            } catch let error {
                print(error.localizedDescription)
            }
            guard let `self` = self else { return }
            let newVc = SignUpViewController()
            newVc.modalPresentationStyle = .fullScreen
            self.present(newVc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, signInAction, cancelAction], completion: nil)
    }
    
    private func makeBackgroundBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView = blurEffectView
        view.addSubview(blurView!)
    }
}

extension AccountSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

extension AccountSettingsViewController: DataReloaderDelegate {
    func reloadInfo() {
        if let email = accountSettingsModel.email {
            emailTextField.text = email
        }
        if let name = accountSettingsModel.name {
            nameTextField.text = name
        }
        if let age = accountSettingsModel.age {
            ageTextField.text = "\(age)"
        }
    }
}
