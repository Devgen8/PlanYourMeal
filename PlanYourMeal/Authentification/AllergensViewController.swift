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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergensTableView.dataSource = self
        Design.styleFilledButton(readyToGoButton)
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
        view.window?.rootViewController = TabBarViewController()
        view.window?.makeKeyAndVisible()
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
        
        cell.nameOfAllergen.text = indexPath.section == 0 ? Diet.dietType[indexPath.row] : Allergens.allergens[indexPath.row]
        if (cell.nameOfAllergen.text == "pecatarian" ||
            cell.nameOfAllergen.text == "vegan" ||
            cell.nameOfAllergen.text == "vegetarian") {
            cell.allergenSwitcher.isOn = false
        }
        
        return cell
    }
}
