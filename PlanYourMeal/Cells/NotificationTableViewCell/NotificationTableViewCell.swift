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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timePicker.dataSource = self
        timePicker.delegate = self
        decorationView.layer.cornerRadius = 20
    }
    
    @IBAction func tickTapped(_ sender: UIButton) {
        if !NotificationService.isAbleToNotify {
            let time = Int(timePicker.selectedRow(inComponent: 0)) + 1
            if let notificationType = notificationLabel.text?.components(separatedBy: " ").first {
                NotificationService.notifyUser(about: notificationType, at: time)
            }
            tickButton.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
        } else {
            delegate?.sendAlert()
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

