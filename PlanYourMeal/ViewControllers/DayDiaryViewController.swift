//
//  DayDiaryViewController.swift
//  PlanYourMeal
//
//  Created by мак on 01/12/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DayDiaryViewController: UIViewController {
    
    var positionInPages: Int?
    var cellIdentifier = "MealTableViewCell"
    var mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    var defaultMealPhotos = [#imageLiteral(resourceName: "Breakfast"), #imageLiteral(resourceName: "Lunch"), #imageLiteral(resourceName: "Dinner-1"), #imageLiteral(resourceName: "Snack")]
    var recomendedCalories = ["350-450", "450-550", "400-500", "0"]
    var calendar = Calendar.current
    var todayDate = Date()
    var weekday = ""
    var meals = [Int:MealDataModel]()
    var chosenMealPhotos = [Int:UIImage]()
    var imageURLs = [Int:String]()
    @IBOutlet weak var newMealButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var mealsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView.dataSource = self
        mealsTableView.delegate = self
        
        let nibCell = UINib(nibName: cellIdentifier, bundle: nil)
        mealsTableView.register(nibCell, forCellReuseIdentifier: cellIdentifier)
        if let date = calendar.date(byAdding: .day, value: positionInPages ?? 0, to: todayDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            
            weekday = dateFormatter.string(from: date)
            calendarLabel.text = weekday
        }
        Design.styleFilledButton(newMealButton)
        makeRequestForMeals()
    }
    @IBAction func newMealTapped(_ sender: UIButton) {
        var destinationViewController = AddingMealTypeViewController()
        destinationViewController.delegate = self
        present(destinationViewController, animated: true, completion: nil)
    }
    
    func makeRequestForMeals() {
        meals = [Int:MealDataModel]()
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error: can not read meals info")
                } else {
                    var indexOfMeal = 0
                    guard snapshot != nil else { return }
                    for document in snapshot!.documents {
                        var meal = MealDataModel()
                        if document.data()["mealType"] as? String == self?.mealTypes[indexOfMeal] {
                            meal.name = document.data()["name"] as? String
                            meal.calories = document.data()["calories"] as? Float
                            meal.image = document.data()["image"] as? String
                        }
                        self?.meals[indexOfMeal] = meal
                        if let photo = meal.image {
                            self?.imageURLs[indexOfMeal] = photo
                            self?.mealsTableView.reloadData()
                        } else {
                            self?.chosenMealPhotos[indexOfMeal] = self?.defaultMealPhotos[indexOfMeal]
                        }
                        self?.mealsTableView.reloadData()
                        indexOfMeal += 1
                    }
                    self?.mealsTableView.reloadData()
                    self?.downloadMealImages()
                }
            }
        }
    }
    
    func downloadImageFromURL(_ url: URL?, at index: Int) {
        guard url != nil else { return }
        URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
                else { return }
                self?.chosenMealPhotos[index] = UIImage(data: data)
        }.resume()
    }
    
    func downloadMealImages() {
        DispatchQueue.main.async {
            self.mealsTableView.reloadData()
        }
        for imageIndexPair in imageURLs {
            downloadImageFromURL(URL(string: imageIndexPair.value), at: imageIndexPair.key)
        }
    }
    
}

extension DayDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        if let mealName = meals[indexPath.row]?.name {
            cell.mealTypeLabel.text = mealName
        } else {
            cell.mealTypeLabel.text = mealTypes[indexPath.row]
        }
        
        if let mealCalories = meals[indexPath.row]?.calories {
            cell.caloriesLabel.text = "\(Int(mealCalories))"
        } else {
            cell.caloriesLabel.text = "Recomended: \(recomendedCalories[indexPath.row]) kcal"
        }
        
        cell.mealImageView.image = chosenMealPhotos[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationViewController = PickMealViewController()
        destinationViewController.delegate = self
        destinationViewController.weekday = weekday
        destinationViewController.mealType = "\(indexPath.row + 1)\(mealTypes[indexPath.row])"
        present(destinationViewController, animated: true, completion: nil)
    }
    
}

extension DayDiaryViewController: AddingNewMealDelegate {
    func getInfoForNewMeal(image: UIImage, calories: String, name: String) {
        mealTypes += [name]
        recomendedCalories += [calories]
        defaultMealPhotos += [image]
        mealsTableView.reloadData()
    }
}

extension DayDiaryViewController: DataReloaderDelegate {
    func reloadInfo() {
        makeRequestForMeals()
    }
}
