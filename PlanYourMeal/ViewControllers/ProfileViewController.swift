//
//  ProfileViewController.swift
//  PlanYourMeal
//
//  Created by мак on 09/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let cellIdentifier = "SettingsTableViewCell"
    
    let settingsNamesForSection1 = ["Personal details", "Food preferences"]
    let settingsnamesForSection2 = ["Account settings", "Notification settings"]
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibCell = UINib(nibName: cellIdentifier, bundle: nil)
        settingsTableView.register(nibCell, forCellReuseIdentifier: cellIdentifier)
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        
        settingsTableView.backgroundColor = .green
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .green
    }
    
    
    
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: present(UserGoalViewController(), animated: true, completion: nil)
        case 1: present(AllergensViewController(), animated: true, completion: nil)
        default: return
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Profile" : "Account"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsTableViewCell
        
        cell.settingNameLabel.text = indexPath.section == 0 ? settingsNamesForSection1[indexPath.row] : settingsnamesForSection2[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
