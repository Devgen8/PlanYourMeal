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
    
    lazy var notificationSettingsModel = NotificationSettingsModel(with: self)
    var userNotifications = [String:Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTableView.dataSource = self
        notificationsTableView.delegate = self
        notificationSettingsModel.getUsersNotifications()
    }
}

extension NotificationSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("NotificationTableViewCell", owner: self, options: nil)?.first as! NotificationTableViewCell
        
        cell.delegate = self
        let notificationType = NotificationService.notificationTypes[indexPath.section]
        cell.notificationLabel.text = "\(notificationType) time is "
        if let time = userNotifications[notificationType] {
            cell.isChosen = true
            cell.tickButton.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
            cell.timePicker.selectRow(time - 1, inComponent: 0, animated: true)
            cell.time = time
        }
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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

extension NotificationSettingsViewController: UITableViewDelegate {
    
}

extension NotificationSettingsViewController: AlertSenderDelegate {
    func sendAlert() {
        let title = "Just one detail!"
        let message = "Notifications can not be sent to you because we do not have you permission. Please change it in your settings to let us notify you."
        let alert = NotificationService.createAlert(title: title, message: message)
        self.present(alert, animated: true, completion: nil)
    }
}

extension NotificationSettingsViewController: DataReloaderDelegate {
    func reloadInfo() {
        userNotifications = notificationSettingsModel.userNotifications
        notificationsTableView.reloadData()
    }
}
