//
//  AlertService.swift
//  PlanYourMeal
//
//  Created by мак on 15/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation

class AlertService {
    static func showAlert(on vc: UIViewController, style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction], completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        vc.present(alert, animated: true, completion: nil)
    }
}
