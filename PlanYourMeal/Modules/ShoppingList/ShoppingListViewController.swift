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
    @IBOutlet weak var weekdayPicker: UIPickerView!
    
    private var userShoppingItems = [Int:[ShoppingListItem]]()
    private var mealTypes = [String]()
    private var shoppingItemsStatus = [Int:[Bool]]()
    lazy var shoppingListModel = ShoppingListModel(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.dataSource = self
        listTableView.delegate = self
        weekdayPicker.dataSource = self
        weekdayPicker.delegate = self
        shoppingListModel.getMealTypes()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    private func setUpNavigationBar() {
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
            cell.delegate = shoppingListModel
            cell.amount.text = "\(itemForCell.weight ?? 0) g"
            cell.ingredient.text = itemForCell.name
            cell.rowIndex = indexPath.row
            cell.sectionIndex = indexPath.section
            
            cell.checkButton.setImage(nil, for: .normal)
            if itemForCell.bought {
                cell.checkButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell.decorationView.backgroundColor = .systemGreen
                cell.decorationView.layer.shadowColor = UIColor.systemGreen.cgColor
            } else {
                cell.checkButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
                cell.decorationView.backgroundColor = .systemRed
                cell.decorationView.layer.shadowColor = UIColor.systemRed.cgColor
            }
        }
        return cell
    }
}

extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 15, y: 8, width: 320, height: 30)
        headerLabel.font = UIFont.boldSystemFont(ofSize: 26)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textColor = .label

        let headerView = UIView()
        headerView.backgroundColor = .tertiarySystemBackground
        headerView.layer.cornerRadius = 8
        headerView.addSubview(headerLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}

extension ShoppingListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let weekdayName = shoppingListModel.getWeekdayName(with: row)
        return weekdayName ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        shoppingListModel.weekday = shoppingListModel.getWeekdayName(with: row) ?? ""
        shoppingListModel.getMealTypes()
    }
}

extension ShoppingListViewController: DataReloaderDelegate {
    func reloadInfo() {
        mealTypes = shoppingListModel.mealTypes
        shoppingItemsStatus = shoppingListModel.shoppingItemsStatus
        userShoppingItems = shoppingListModel.userShoppingItems
        listTableView.reloadData()
    }
}
