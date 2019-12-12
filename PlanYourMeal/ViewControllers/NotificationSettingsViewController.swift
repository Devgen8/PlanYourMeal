//
//  NotificationSettingsViewController.swift
//  PlanYourMeal
//
//  Created by мак on 12/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {

    @IBOutlet weak var notificationsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsTableView.dataSource = self
        notificationsTableView.delegate = self
        //notificationsTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
    }
}

extension NotificationSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("NotificationTableViewCell", owner: self, options: nil)?.first as! NotificationTableViewCell
        
        cell.cellDelegate = self
        let notificationType = NotificationService.notificationTypes[indexPath.section]
        cell.notificationLabel.text = "\(notificationType) time is "
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let arrayOfTypes = NotificationService.notificationTypes
        switch section {
        case 0: return arrayOfTypes[0]
        case 1: return arrayOfTypes[1]
        case 2: return arrayOfTypes[2]
        case 3: return arrayOfTypes[3]
        case 4: return arrayOfTypes[4]
        default: return ""
        }
    }
}

extension NotificationSettingsViewController: UITableViewDelegate {
    
}

extension NotificationSettingsViewController: MyCellProtocol {
    func didTapCell() {
        let title = "Just one detail!"
        let message = "Notifications can not be sent to you because we don not have you permission. Please change it in your settings to let us notify you."
        let alert = NotificationService.createAlert(title: title, message: message)
        self.present(alert, animated: true, completion: nil)
    }
}