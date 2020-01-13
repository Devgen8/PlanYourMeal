//
//  NotificationSettingsModel.swift
//  PlanYourMeal
//
//  Created by мак on 12/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class NotificationSettingsModel {
    
    var userNotifications = [String:Int]()
    var dataReloaderDelegate: DataReloaderDelegate?
    
    init(with delegate: DataReloaderDelegate) {
        dataReloaderDelegate = delegate
        getUsersNotifications()
    }
    
    func getUsersNotifications() {
        var notificationIndex = 0
        for notificationType in NotificationService.notificationTypes {
            notificationIndex += 1
            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users/\(userId)/Notifications").document(notificationType).getDocument { [weak self] (document, error) in
                    guard let `self` = self else { return }
                    guard error == nil else {
                        print(error?.localizedDescription ?? "Error; can not read data about notifications")
                        return
                    }
                    if let time = document?.data()?["time"] as? Int {
                        self.userNotifications[notificationType] = time
                    }
                    if notificationIndex == NotificationService.notificationTypes.count {
                        self.dataReloaderDelegate?.reloadInfo?()
                    }
                }
            }

        }
    }
}
