//
//  NotificationTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 16/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var decorationView: UIView!
    var delegate: AlertSenderDelegate?
    var notificationsModel = NotificationsModel()
    var isChosen = false
    var time: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timePicker.dataSource = self
        timePicker.delegate = self
        decorationView.layer.cornerRadius = 20
    }
    
    @IBAction func tickTapped(_ sender: UIButton) {
        guard NotificationService.isAbleToNotify == true else {
            delegate?.sendAlert()
            return
        }
        if isChosen {
            if let notificationType = notificationLabel.text?.components(separatedBy: " ").first {
                notificationsModel.deleteNotificationsData(notificationType: notificationType)
            }
            tickButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
            isChosen = false
        } else {
            let time = Int(timePicker.selectedRow(inComponent: 0)) + 1
            if let notificationType = notificationLabel.text?.components(separatedBy: " ").first {
                NotificationService.notifyUser(about: notificationType, at: time)
                notificationsModel.updateNotificationsData(notificationType: notificationType, time: time)
                self.time = time
            }
            tickButton.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
            isChosen = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: UIPickerViewDelegate
extension NotificationTableViewCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let hour = "\(row + 1)"
        return hour
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row + 1 != time {
            isChosen = false
            tickButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        } else {
            isChosen = true
            tickButton.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
        }
    }
}

// MARK: UIPickerViewDataSource
extension NotificationTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 24
    }
}

