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
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        ageTextField.delegate = self
        
        setUpOutlets()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("users").document(currentUser!.uid).getDocument { [unowned self] (snapshot, error) in
            guard error == nil else {
                print("Error reading data: \(error?.localizedDescription ?? "nil")")
                return
            }
            self.emailTextField.text = self.currentUser?.email
            if let age = snapshot?.data()?["age"] as? Int {
                self.ageTextField.text = "\(age)"
            }
            self.nameTextField.text = snapshot?.data()?["name"] as? String
        }
    }
    
    func setUpOutlets() {
        errorLabel.alpha = 0
        Design.styleTextField(nameTextField)
        Design.styleTextField(ageTextField)
        Design.styleTextField(emailTextField)
        Design.styleFilledButton(okButton)
        Design.styleFilledButton(deleteAccButton)
        Design.styleFilledButton(logOutButton)
        passwordButtonDesign()
    }
    
    func passwordButtonDesign() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: passwordButton.frame.height - 2, width: passwordButton.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        passwordButton.layer.addSublayer(bottomLine)
        passwordButton.titleLabel?.textAlignment = .left
        var pass = ""
        for _ in Password.userPassword { pass += "•" }
        passwordButton.setTitle(pass, for: .normal)
    }
    
    @IBAction func emailEditingFinished(_ sender: UITextField) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        db.collection("users").document(currentUser!.uid).updateData(["email" : email]) { (error) in
            guard error == nil else {
                self.showError("Something went wrong with email changing...")
                return
            }
        }
        currentUser?.updateEmail(to: email, completion: { [unowned self] (error) in
            guard error == nil else {
                self.showError("Something went wrong with email changing...")
                return
            }
        })
    }
    @IBAction func nameEditingFinished(_ sender: UITextField) {
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        db.collection("users").document(currentUser!.uid).updateData(["name" : name]) { (error) in
            guard error == nil else {
                self.showError("Something went wrong with name changing...")
                return
            }
        }
    }
    @IBAction func ageEditingFinished(_ sender: UITextField) {
        let age = ageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        db.collection("users").document(currentUser!.uid).updateData(["age" : age]) { (error) in
            guard error == nil else {
                self.showError("Something went wrong with age changing...")
                return
            }
        }
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
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        let signOutAction = UIAlertAction(title: "Sign In", style: .destructive) { [weak self] (action) in
            guard let `self` = self else { return }
            let newVc = SignInViewController()
            newVc.modalPresentationStyle = .fullScreen
            self.present(newVc, animated: true, completion: nil)
        }
        let signInAction = UIAlertAction(title: "Sign Up", style: .destructive) { [weak self] (action) in
            guard let `self` = self else { return }
            let newVc = SignUpViewController()
            newVc.modalPresentationStyle = .fullScreen
            self.present(newVc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, signInAction, cancelAction], completion: nil)
    }
    
    func makeBackgroundBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView = blurEffectView
        view.addSubview(blurView!)
    }
    
    func showError(_ error: String) {
        errorLabel.alpha = 1
        errorLabel.text = error
    }
}

extension AccountSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
