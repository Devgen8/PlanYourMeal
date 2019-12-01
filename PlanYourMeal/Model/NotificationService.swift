//
//  NotificationService.swift
//  PlanYourMeal
//
//  Created by мак on 17/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService {
    static func notifyUser(about type: String, at time: Int) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        if type.lowercased() == "sleep" {
            content.body = "It's time to sleep! Go to bed now and you health will thank you!"
        } else {
            content.body = "It's \(type.lowercased()) time! Check what you got today!"
        }
        content.categoryIdentifier = "\(type.lowercased())Reminder"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = time
//        dateComponents.minute = 15
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
    
    static var isAbleToNotify: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    static func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }
    
    static let notificationTypes = ["Breakfast", "Launch", "Dinner", "Snack", "Sleep"]
}
