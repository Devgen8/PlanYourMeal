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
    
    var usersAllergensInfo : [String]?
    
    var dietType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergensTableView.dataSource = self
        Design.styleFilledButton(readyToGoButton)
        let cast = presentingViewController as? UserDataViewController
        if cast == nil {
            readyToGoButton.setTitle("OK", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let cast = presentingViewController as? UserDataViewController
        if cast == nil {
            let db = Firestore.firestore()
            DispatchQueue.main.async {
                let uid = Auth.auth().currentUser?.uid ?? ""
                db.collection("/users/\(uid)/Additional info").document("Allergens").getDocument { [unowned self] (snapshot, error) in
                    if error != nil {
                        print("Error reading data: \(error?.localizedDescription ?? "Error")")
                    } else {
                        self.usersAllergensInfo = snapshot?.data()?["allergens"] as? [String]
                    }
                }
                db.collection("/users/\(uid)/Additional info").document("Diet").getDocument { [unowned self] (snapshot, error) in
                    guard (error == nil) else {
                        print("Error reading data: \(error?.localizedDescription ?? "Error")")
                        return
                    }
                    if let dietType = snapshot?.data()?["dietType"] as? String {
                        self.dietType = dietType
                    }
                }
            }
        }
    }
    
    @IBAction func readyTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        db.collection("/users/\(Auth.auth().currentUser!.uid)/Additional info").document("Allergens").setData(["allergens":AllergensTableViewCell.userAllergens]) {(error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                }
            }
        if (AllergensTableViewCell.usersDietType != nil) {
            db.collection("/users/\(Auth.auth().currentUser!.uid)/Additional info").document("Diet").setData(["dietType":AllergensTableViewCell.usersDietType!]) {(error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                }
            }
        }
        if let _ = presentingViewController as? UserDataViewController {
            view.window?.rootViewController = TabBarViewController()
            view.window?.makeKeyAndVisible()
        } else {
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
        case 1: return "Ingredints you want to have in your diet:"
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
        
        if usersAllergensInfo != nil {
            usersAllergensInfo! += [(dietType ?? "")]
        }
        
        let textForCell = indexPath.section == 0 ? Diet.dietType[indexPath.row] : Allergens.allergens[indexPath.row]
        cell.nameOfAllergen.text = textForCell
        
        let cast = presentingViewController as? UserDataViewController
        if cast == nil {
            if usersAllergensInfo?.contains(textForCell) ?? [""].contains(textForCell) {
                cell.allergenSwitcher.isOn = indexPath.section == 0 ? true : false
            } else {
                cell.allergenSwitcher.isOn = indexPath.section == 0 ? false : true
            }
        } else {
            if (cell.nameOfAllergen.text == "pecatarian" ||
                cell.nameOfAllergen.text == "vegan" ||
                cell.nameOfAllergen.text == "vegetarian") {
                cell.allergenSwitcher.isOn = false
            }
        }
        
        return cell
    }
}
