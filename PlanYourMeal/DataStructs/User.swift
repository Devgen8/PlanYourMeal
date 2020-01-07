//
//  User.swift
//  PlanYourMeal
//
//  Created by мак on 15/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation

struct User: Decodable {
    var email: String?
    var name: String?
    static var password = ""
    static var dietType: String?
    static var allergensInfo: [String]?
    static var dailyCalories: Int?
    static var age: Int?
    static var goal: String?
    static var height: Float?
    static var weight: Float?
    static var gender: String?
}
