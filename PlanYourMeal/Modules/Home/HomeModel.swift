//
//  HomeModel.swift
//  PlanYourMeal
//
//  Created by мак on 06/01/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

class HomeModel {
    
    var weekday = ""
    var todayCalories: Int?
    var dailyCalories: Int?
    var usersName: String?
    private var delegate: DataReloaderDelegate?
    
    init(with reloaderDelegate: DataReloaderDelegate) {
        delegate = reloaderDelegate
    }
    
    func getDataFromDatabase() {
        getGeneralUserInfo()
        checkWaterInfo()
        getUsersImage()
        getUsersInfo()
    }
    
    private func checkWaterInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).getDocument { [weak self] (snapshot, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read data about last session")
                    return
                }
                guard let `self` = self else { return }
                if let lastSessionTimeStamp = snapshot?.data()?["lastSession"] as? Timestamp {
                    let lastSessionDate = lastSessionTimeStamp.dateValue()
                    let timePeriod = Calendar.current.dateComponents([.day], from: lastSessionDate, to: Date())
                    var weekdaysForUpadte = [String]()
                    if let dayDifferance = timePeriod.day, dayDifferance > 6 {
                        weekdaysForUpadte = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                    }
                    if let dayDifferance = timePeriod.day, dayDifferance <= 6 {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        for daysAgo in stride(from: 1, to: dayDifferance + 1, by: 1) {
                            if let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) {
                                let weekdayName = dateFormatter.string(from: date)
                                weekdaysForUpadte += [weekdayName]
                            }
                        }
                    }
                    self.updateWaterInfo(for: weekdaysForUpadte)
                }
                Firestore.firestore().collection("users").document(userId).updateData(["lastSession":Date()])
            }
        }
    }
    
    private func updateWaterInfo(for days: [String]) {
        for weekdayForUpdate in days {
            if let userId = Auth.auth().currentUser?.uid { Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekdayForUpdate).updateData(["waterGlassesNumber":0])
            }
        }
    }
    
    private func getWeekdayName(with offset: Int) -> String? {
        var weekdayName: String?
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekdayName = dateFormatter.string(from: date)
        }
        return weekdayName
    }
    
    private func getGeneralUserInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            weekday = getWeekdayName(with: 0) ?? ""
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).getDocument { [weak self] (snapshot, error) in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "Error: can not read data about allergens")
                        return
                    }
                    guard let `self` = self else { return }
                    if let caloriesForToday = snapshot?.data()?["todayCalories"] as? Int {
                        self.todayCalories = caloriesForToday
                        self.delegate?.reloadInfo?()
                    }
                }
            Firestore.firestore().collection("users").document(userId).collection("Additional info").document("Allergens").getDocument { (snapshot, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read allergens data")
                    return
                }
                User.dietType = snapshot?.data()?["dietType"] as? String
                User.allergensInfo = snapshot?.data()?["allergens"] as? [String]
            }
            Firestore.firestore().collection("users").document(userId).collection("Additional info").document("Diet").getDocument { [weak self] (snapshot, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read calories data")
                    return
                }
                guard let `self` = self else { return }
                if let calories = snapshot?.data()?["dailyCalories"] as? Int {
                    User.dailyCalories = calories
                    self.dailyCalories = calories
                    self.delegate?.reloadInfo?()
                } else {
                    self.calculateUsersDailyCalories()
                }
            }
        }
    }
    
    private func calculateUsersDailyCalories() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Additional info").document("Goal").getDocument { [weak self] (snapshot, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read calories data")
                    return
                }
                guard let `self` = self else { return }
                if let usersGoal = snapshot?.data()?["goal"] as? String {
                    User.goal = usersGoal
                    self.getUsersAge()
                }
            }
        }
    }
    
    private func getUsersAge() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).getDocument { [weak self] (snapshot, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read info about age")
                    return
                }
                guard let `self` = self else { return }
                if let age = snapshot?.data()?["age"] as? Int {
                    User.age = age
                    self.getUsersBodyType()
                }
            }
        }
    }
    
    private func getUsersBodyType() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Additional info").document("Body type").getDocument { [weak self] (snapshot, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read info about age")
                    return
                }
                guard let `self` = self else { return }
                if let gender = snapshot?.data()?["gender"] as? String,
                    let height = snapshot?.data()?["height"] as? Float,
                    let weight = snapshot?.data()?["weight"] as? Float {
                    User.gender = gender
                    User.height = height
                    User.weight = weight
                    self.analizeUsersDataForCaloriesCalculation()
                }
            }
        }
    }
    
    private func analizeUsersDataForCaloriesCalculation() {
        var calories: Float = 0.0
        if User.gender == "Male" {
            let coef1: Float = 66.473
            let coef2: Float = 13.7516 * (User.weight ?? 0)
            let coef3: Float = 5.0033 * (User.height ?? 0)
            let coef4: Float = 6.755 * Float(User.age ?? 0)
            calories = coef1 + coef2 + coef3 - coef4
            calories *= 1.375
        } else {
            let coef1: Float = 5.0955
            let coef2: Float = 9.5634 * (User.weight ?? 0)
            let coef3: Float = 1.8496 * (User.height ?? 0)
            let coef4: Float = 4.6756 * Float(User.age ?? 0)
            calories = coef1 + coef2 + coef3 - coef4
            calories *= 1.375
        }
        User.dailyCalories = Int(calories)
        dailyCalories = Int(calories)
        delegate?.reloadInfo?()
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Additional info").document("Diet").setData(["dailyCalories":Int(calories)])
        }
    }
    
    func getUsersImage() {
        if let userId = Auth.auth().currentUser?.uid {
            Storage.storage().reference().child("\(userId)").getData(maxSize: 1 * 4048 * 4048) { [weak self] (data, error) in
                guard let `self` = self else { return }
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not get user image")
                    return
                }
                if let source = data, let downloadImage = UIImage(data: source) {
                    self.delegate?.updateImageView?(with: downloadImage, for: 0)
                }
            }
        }
    }
    
    func getUsersInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document("\(userId)").getDocument { [weak self] (document, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not get users name")
                    return
                }
                if let name = document?.data()?["name"] as? String {
                    self?.usersName = name
                    self?.delegate?.reloadInfo?()
                }
            }
        }
    }
}
