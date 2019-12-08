//
//  AddingMealTypeViewController.swift
//  PlanYourMeal
//
//  Created by мак on 02/12/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class AddingMealTypeViewController: UIViewController {

    @IBOutlet weak var mealTypeImage: UIImageView!
    @IBOutlet weak var mealTypeNameTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var delegate: AddingNewMealDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        designElements()
    }
    
    func designElements() {
        setUpMealImageView()
        Design.styleFilledButton(addButton)
        Design.styleTextField(mealTypeNameTextField)
        Design.styleTextField(caloriesTextField)
        errorLabel.isHidden = true
    }
    
    func setUpMealImageView() {
        mealTypeImage.layer.cornerRadius = 45
        mealTypeImage.layer.borderWidth = 0.1
        mealTypeImage.layer.borderColor = UIColor.white.cgColor
        mealTypeImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        mealTypeImage.isUserInteractionEnabled = true
    }
    
    @objc func handlePickingPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        if caloriesTextField.text != "", mealTypeNameTextField.text != "" {
            delegate?.getInfoForNewMeal(image: mealTypeImage.image ?? #imageLiteral(resourceName: "AddPhoto"), calories: mealTypeNameTextField.text ?? "0", name: mealTypeNameTextField.text ?? "New meal")
            dismiss(animated: true, completion: nil)
        } else {
            errorLabel.isHidden = false
            errorLabel.text = "You should complete all fields"
        }
    }
}

extension AddingMealTypeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            mealTypeImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
