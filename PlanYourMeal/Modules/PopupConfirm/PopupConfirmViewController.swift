//
//  PopupConfirmViewController.swift
//  PlanYourMeal
//
//  Created by мак on 15/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth

class PopupConfirmViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var popupConfirmModel = PopupConfirmModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 25.0
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        Design.styleHollowButton(cancelButton)
        Design.styleHollowButton(deleteButton)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        let presentingVC = presentingViewController as! AccountSettingsViewController
        presentingVC.blurView?.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        popupConfirmModel.deleteUser()
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        present(signUpVC, animated: true, completion: nil)
    }
    
}
