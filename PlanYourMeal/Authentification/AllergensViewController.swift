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
    
    let arrayOfAllergens = Allergens()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergensTableView.dataSource = self
        Design.styleFilledButton(readyToGoButton)
    }
    
    @IBAction func readyTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        db.collection("/users/\(Auth.auth().currentUser!.uid)/Additional info").document("Allergens").setData(["allergens":AllergensTableViewCell.userAllergens]) {(error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
        view.window?.rootViewController = TabBarViewController()
        view.window?.makeKeyAndVisible()
    }
}

extension AllergensViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfAllergens.allergens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("AllergensTableViewCell", owner: self, options: nil)?.first as! AllergensTableViewCell
        
        cell.nameOfAllergen.text = arrayOfAllergens.allergens[indexPath.row]
        
        return cell
    }
}
