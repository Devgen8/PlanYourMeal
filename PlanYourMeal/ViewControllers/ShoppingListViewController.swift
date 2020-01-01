//
//  ShoppingListViewController.swift
//  PlanYourMeal
//
//  Created by мак on 09/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ShoppingListViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    
    var userShoppingItems = [Int:[ShoppingListItem]]()
    var mealTypes = [String]()
    var mealTypesReference = Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("Meals")
    var weekday = ""
    var refreshControl = UIRefreshControl()
    var shoppingItemsStatus = [Int:[Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(getMealTypes), for: .valueChanged)
        setUpTodayWeekday()
        getMealTypes()
    }
    
    func setUpTodayWeekday() {
        if let date = Calendar.current.date(byAdding: .day, value: 0, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekday = dateFormatter.string(from: date)
        }
    }
    
    @objc func getMealTypes() {
        mealTypesReference.document(weekday).getDocument { [weak self] (snapshot, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error: can not read meal types")
                return
            }
            if let meals = snapshot?.data()?["mealTypes"] as? [String] {
                self?.mealTypes = meals
            }
            self?.getUserShoppingItems()
        }
    }
    
    func getUserShoppingItems() {
        mealTypesReference.document(weekday).collection("MealTypes").getDocuments { [weak self] (snapshot, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error: can not read meal types documents")
                return
            }
            if let docs = snapshot?.documents {
                guard let `self` = self else { return }
                for document in docs {
                    var indexOfDocument = 0
                    var documentMealType = document.data()["mealType"] as? String
                    for mealType in self.mealTypes {
                        if documentMealType == mealType {
                            break
                        }
                        indexOfDocument += 1
                    }
                    var shoppingListItemsForMeal = [ShoppingListItem]()
                    let ingredientNames = document.data()["ingredientNames"] as? [String]
                    let ingredientWeights = document.data()["ingredientWeights"] as? [Float]
                    let ingredientStatus = document.data()["ingredientStatus"] as? [Bool]
                    if let ingredients = ingredientNames {
                        var indexOfIngredient = 0
                        self.shoppingItemsStatus[indexOfDocument] = []
                        for ingredientName in ingredients {
                            var shoppingListItem = ShoppingListItem()
                            shoppingListItem.name = ingredientName
                            shoppingListItem.weight = ingredientWeights?[indexOfIngredient]
                            shoppingListItem.bought = ingredientStatus?[indexOfIngredient] ?? false
                            shoppingListItemsForMeal.append(shoppingListItem)
                            indexOfIngredient += 1
                            self.shoppingItemsStatus[indexOfDocument]?.append(shoppingListItem.bought)
                        }
                    }
                    self.userShoppingItems[indexOfDocument] = shoppingListItemsForMeal
                }
            }
            self?.listTableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    func setUpNavigationBar() {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
}

extension ShoppingListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userShoppingItems[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mealTypes[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ShoppingListTableViewCell", owner: self, options: nil)?.first as! ShoppingListTableViewCell
        
        if let itemForCell = userShoppingItems[indexPath.section]?[indexPath.row] {
            cell.ingredientItem = itemForCell
            cell.delegate = self
            cell.amount.text = "\(itemForCell.weight ?? 0) g"
            cell.ingredient.text = itemForCell.name
            cell.rowIndex = indexPath.row
            cell.sectionIndex = indexPath.section
            
            cell.checkButton.setImage(nil, for: .normal)
            if itemForCell.bought {
                cell.checkButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            } else {
                cell.checkButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
            }
        }
        return cell
    }
}

extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

extension ShoppingListViewController: IngredientStatusDelegate {
    func changeIngredientStatus(for item: ShoppingListItem, section: Int, row: Int) {
        if let boughtStatus = userShoppingItems[section]?[row].bought {
            userShoppingItems[section]?[row].bought = !boughtStatus
            shoppingItemsStatus[section]?[row] = !boughtStatus
            if let itemsForSectionStatus = shoppingItemsStatus[section] {
                mealTypesReference.document(weekday).collection("MealTypes").document(mealTypes[section]).updateData(["ingredientStatus":itemsForSectionStatus])
            }
            listTableView.reloadData()
        }
    }
    
//    func changeIngredientStatus(for item: ShoppingListItem) {
//        var mealTypeIndex = 0
//        for mealItems in userShoppingItems {
//            var ingredientIndex = 0
//            for ingredient in mealItems.value {
//                if ingredient.name == item.name {
//                    if userShoppingItems[mealTypeIndex]?[ingredientIndex].bought ?? false {
//                        userShoppingItems[mealTypeIndex]?[ingredientIndex].bought = false
//                    } else {
//                        userShoppingItems[mealTypeIndex]?[ingredientIndex].bought = true
//                        let boughtItem = userShoppingItems[mealTypeIndex]?.remove(at: ingredientIndex) ?? ShoppingListItem()
//                        userShoppingItems[mealTypeIndex]?.append(boughtItem)
//                    }
//                }
//                ingredientIndex += 1
//            }
//            mealTypeIndex += 1
//        }
//        listTableView.reloadData()
//
//    }
    
    
}
