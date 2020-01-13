//
//  PopupPasswordModel.swift
//  PlanYourMeal
//
//  Created by мак on 12/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class PopupPasswordModel {
    
    var errorHandlerDelegate: ErrorHandlerDelegate?
    
    init(with errorHandler: ErrorHandlerDelegate) {
        errorHandlerDelegate = errorHandler
    }
    
    func updateUsersPassword(currentPassword: String, newPassword: String, confirmPassword: String) {
        guard currentPassword == User.password else {
            errorHandlerDelegate?.handleError(error: "Try again. Your current password is not right")
            return
        }
        guard newPassword == confirmPassword, newPassword != "" else {
            errorHandlerDelegate?.handleError(error: "Try again. Your new password doesn't match with confirmation")
            return
        }
        guard newPassword.count >= 8 else {
            errorHandlerDelegate?.handleError(error: "Password should be at least 8 symbols!")
            return
        }
        User.password = newPassword
        Auth.auth().currentUser?.updatePassword(to: User.password, completion: { [weak self] (error) in
            guard let `self` = self else { return }
            guard error == nil else {
                self.errorHandlerDelegate?.handleError(error: "Something went wrong with password changing...")
                return
            }
        })
    }
}
