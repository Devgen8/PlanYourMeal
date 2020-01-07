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
    
    @IBOutlet weak private var allergensTableView: UITableView!
    @IBOutlet weak private var readyToGoButton: UIButton!
    private lazy var allergensModel = AllergensModel(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergensTableView.dataSource = self
        allergensTableView.delegate = self
        Design.styleFilledButton(readyToGoButton)
        let cast = presentingViewController as? UserDataViewController
        if cast == nil {
            readyToGoButton.setTitle("OK", for: .normal)
        }
    }
    
    @IBAction private func readyTapped(_ sender: UIButton) {
        allergensModel.deliverDataToDatabase()
        if let _ = presentingViewController as? UserDataViewController {
            allergensModel.createMealSchedule()
            let newVC = TabBarViewController()
            newVC.modalPresentationStyle = .fullScreen
            present(newVC, animated: true, completion: nil)
        } else {
            User.allergensInfo = allergensModel.usersAllergensInfo
            User.dietType = allergensModel.dietType
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: UITableViewDataSource
extension AllergensViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Diet type"
        case 1: return "Nutrition preferances"
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
        cell.delegate = allergensModel
        if allergensModel.usersAllergensInfo?.contains(textForCell) ?? false || textForCell == allergensModel.dietType {
            cell.allergenSwitcher.isOn = true
        } else {
            cell.allergenSwitcher.isOn = false
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension AllergensViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: DataReloaderDelegate
extension AllergensViewController: DataReloaderDelegate {
    func reloadInfo() {
        allergensTableView.reloadData()
    }
}
