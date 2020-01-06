//
//  NotificationTableViewCell.swift
//  PlanYourMeal
//
//  Created by мак on 16/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

protocol MyCellProtocol {
    func didTapCell()
}


class NotificationTableViewCell: UITableViewCell {

    var cellDelegate: MyCellProtocol?
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var decorationView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timePicker.dataSource = self
        timePicker.delegate = self
        
        decorationView.layer.cornerRadius = 20
        
        //notificationLabel.text = "Notify you at: "
    }
    @IBAction func tickTapped(_ sender: UIButton) {
//        let value = NotificationService.isAbleToNotify
//        if  value {
//            let time = Int(TimeVariants.timeCases[timePicker.selectedRow(inComponent: 1)]) ?? 12
//            NotificationService.notifyUser(about: notificationLabel.text!, at: time)
//            sender.layer.backgroundColor = sender.layer.backgroundColor == UIColor.systemGray.cgColor ? UIColor.systemGreen.cgColor : UIColor.systemGray.cgColor
//        } else {
//            cellDelegate?.didTapCell()
//        }
        let time = Int(TimeVariants.timeCases[timePicker.selectedRow(inComponent: 0)]) ?? 12
        if let notificationType = notificationLabel.text?.components(separatedBy: " ").first {
            NotificationService.notifyUser(about: notificationType, at: time)
        }
        sender.imageView?.image = #imageLiteral(resourceName: "checked")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension NotificationTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TimeVariants.timeCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(TimeVariants.timeCases[row])
        return TimeVariants.timeCases[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
