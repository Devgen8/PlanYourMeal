//
//  ShoppingListViewController.swift
//  PlanYourMeal
//
//  Created by мак on 09/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit


struct cellData {
    var ingredient: String!
    var amount: String!
}

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var listTableView: UITableView!
    
    var arrayOfCells = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.dataSource = self
        // Do any additional setup after loading the view.
        for i in 0...30 {
            let cell = cellData(ingredient: "\(i)", amount: "\(30 - i)")
            arrayOfCells.append(cell)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ShoppingListTableViewCell", owner: self, options: nil)?.first as! ShoppingListTableViewCell
        
        cell.amount.text = arrayOfCells[indexPath.row].amount
        cell.ingredient.text = arrayOfCells[indexPath.row].ingredient
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}
