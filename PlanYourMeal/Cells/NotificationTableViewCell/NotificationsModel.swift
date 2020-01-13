//
//  NotificationsModel.swift
//  PlanYourMeal
//
//  Created by мак on 12/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class NotificationsModel {
    func updateNotificationsData(notificationType: String, time: Int) {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Notifications").document(notificationType).setData(["time":time])
        }
    }
    
    func deleteNotificationsData(notificationType: String) {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Notifications").document(notificationType).delete()
        }
    }
}
