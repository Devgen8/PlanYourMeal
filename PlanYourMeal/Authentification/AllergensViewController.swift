//
//  AllergensViewController.swift
//  PlanYourMeal
//
//  Created by мак on 27/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

@objc class AllergensViewController: UIViewController {
    
    @IBOutlet weak var allergensTableView: UITableView!
    
    @IBOutlet weak var readyToGoButton: UIButton!
    
    var usersAllergensInfo: [String]?
    var dietType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergensTableView.dataSource = self
        allergensTableView.delegate = self
        Design.styleFilledButton(readyToGoButton)
        let cast = presentingViewController as? UserDataViewController
        if cast == nil {
            readyToGoButton.setTitle("OK", for: .normal)
            readAllergensData()
        }
    }
    
    func readAllergensData() {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid ?? ""
            db.collection("/users/\(userId)/Additional info").document("Allergens").getDocument { [weak self] (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error: can not read data about allergens")
                } else {
                    self?.usersAllergensInfo = snapshot?.data()?["allergens"] as? [String]
                    self?.dietType = snapshot?.data()?["dietType"] as? String
                }
                self?.allergensTableView.reloadData()
            }
    }
    
    func createMealSchedule() {
        if let userId = Auth.auth().currentUser?.uid {
            let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
            let recomendedCalories = ["500-600", "600-700", "500-600", "150"]
            for weekday in weekdays {
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).setData(["mealTypes":mealTypes,"recomendedCalories":recomendedCalories, "waterGlassesNumber":0])
                for mealType in mealTypes {
                    Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").document(mealType).setData(["mealType":mealType])
                }
            }
        }
    }
    
    @IBAction func readyTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        db.collection("/users/\(Auth.auth().currentUser!.uid)/Additional info").document("Allergens").setData([
            "allergens":usersAllergensInfo ?? [String](),
            "dietType":dietType ?? ""])
        if let _ = presentingViewController as? UserDataViewController {
            createMealSchedule()
            let newVC = TabBarViewController()
            newVC.modalPresentationStyle = .fullScreen
            present(newVC, animated: true, completion: nil)
        } else {
            User.allergensInfo = usersAllergensInfo
            User.dietType = dietType
            dismiss(animated: true, completion: nil)
        }
    }
}

extension AllergensViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Diet type"
        case 1: return "Nutrition preferances:"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return Diet.dietType.count
        case 1: return Allergens.allergens.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("AllergensTableViewCell", owner: self, options: nil)?.first as! AllergensTableViewCell
        
        let textForCell = indexPath.section == 0 ? Diet.dietType[indexPath.row] : Allergens.allergens[indexPath.row]
        cell.nameOfAllergen.text = textForCell
        cell.delegate = self
        
        if usersAllergensInfo?.contains(textForCell) ?? false || textForCell == dietType {
            cell.allergenSwitcher.isOn = true
        } else {
            cell.allergenSwitcher.isOn = false
        }
        
        return cell
    }
}

extension AllergensViewController: AllergensInfoChangerDelegate {
    func updateInfo(of allergen: String, to state: Bool) {
        if state {
            if Diet.dietType.contains(allergen) {
                dietType = allergen
            } else {
                if usersAllergensInfo == nil {
                    usersAllergensInfo = [allergen]
                } else {
                    usersAllergensInfo! += [allergen]
                }
            }
        } else {
            if allergen == dietType {
                dietType = nil
            } else {
                usersAllergensInfo = usersAllergensInfo?.filter({ $0 != allergen })
                if usersAllergensInfo?.count == 0 {
                    usersAllergensInfo = nil
                }
            }
        }
        allergensTableView.reloadData()
    }
}
