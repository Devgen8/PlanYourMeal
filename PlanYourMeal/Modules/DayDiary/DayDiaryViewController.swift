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
    private var cellIdentifier = "MealTableViewCell"
    private var mealTypes = [String]()
    private var defaultMealPhotos = [#imageLiteral(resourceName: "Breakfast"), #imageLiteral(resourceName: "Lunch"), #imageLiteral(resourceName: "Dinner-1"), #imageLiteral(resourceName: "Snack")]
    private var recomendedCalories = [String]()
    private var calendar = Calendar.current
    private var todayDate = Date()
    var weekday = ""
    private var meals = [Int:MealDataModel]()
    private var chosenMealPhotos = [Int:UIImage]()
    private var imageURLs = [Int:String]()
    var homeViewControllerDelegate: HomeViewController?
    lazy var dayDiaryModel = DayDiaryModel(with: self)
    @IBOutlet weak var newMealButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var autoPickButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealsTableView.dataSource = self
        mealsTableView.delegate = self
        setupWeekday()
        let nibCell = UINib(nibName: cellIdentifier, bundle: nil)
        mealsTableView.register(nibCell, forCellReuseIdentifier: cellIdentifier)
        Design.styleFilledButton(newMealButton)
        Design.styleFilledButton(autoPickButton)
        activityIndicator.hidesWhenStopped = true
        dayDiaryModel.getDataFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeViewControllerDelegate?.currentPageWeekday = weekday
    }
    
    @IBAction func newMealTapped(_ sender: UIButton) {
        let destinationViewController = AddingMealTypeViewController()
        destinationViewController.delegate = self
        present(destinationViewController, animated: true, completion: nil)
    }
    
    @IBAction func autoPickFoodTapped(_ sender: UIButton) {
        mealsTableView.isHidden = true
        activityIndicator.startAnimating()
        dayDiaryModel.makeRecipesAutoPicking()
    }
    
    private func setupWeekday() {
        if let date = calendar.date(byAdding: .day, value: positionInPages ?? 0, to: todayDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekday = dateFormatter.string(from: date)
            calendarLabel.text = weekday
        }
    }
    
    func makeRequestForMeals() {
        activityIndicator.stopAnimating()
        mealsTableView.isHidden = false
        var totalCalories = 0
        meals = [Int:MealDataModel]()
        if let userId = Auth.auth().currentUser?.uid { Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error: can not read meals info")
                } else {
                    guard snapshot != nil else { return }
                    guard let `self` = self else { return }
                    var documentNumber = 0
                    for document in snapshot!.documents {
                        var indexOfMeal = 0
                        let documentMealType = document.data()["mealType"] as? String
                        for mealType in self.mealTypes {
                            if documentMealType == mealType {
                                break
                            }
                            indexOfMeal += 1
                        }
                        var meal = MealDataModel()
                        meal.name = document.data()["name"] as? String
                        meal.calories = document.data()["calories"] as? Float
                        meal.image = document.data()["image"] as? String
                        if let ingredients = document.data()["ingredientNames"] as? [String] {
                            meal.ingredientNames = ingredients
                        }
                        if let weights = document.data()["ingredientWeights"] as? [Float] {
                            meal.ingredientWeights = weights
                        }
                        meal.url = document.data()["url"] as? String
                        totalCalories += Int(meal.calories ?? 0)
                        documentNumber += 1
                        if documentNumber == snapshot?.documents.count {
                            self.homeViewControllerDelegate?.allDaysCalories[self.weekday] = totalCalories
                            if self.weekday == self.homeViewControllerDelegate?.currentPageWeekday {
                                self.homeViewControllerDelegate?.todayCalories = totalCalories
                            }
                        }
                        self.meals[indexOfMeal] = meal
                        if let photo = meal.image {
                            self.downloadImageFromURL(URL(string: photo), at: indexOfMeal)
                        } else {
                            self.chosenMealPhotos[indexOfMeal] = self.defaultMealPhotos[indexOfMeal]
                        }
                    }
                    self.mealsTableView.reloadData()
                }
            }
        }
    }
    
    private func downloadImageFromURL(_ url: URL?, at index: Int) {
        guard url != nil else { return }
        URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
                else { return }
            DispatchQueue.main.async {
                self?.mealsTableView.reloadData()
            }
                self?.chosenMealPhotos[index] = UIImage(data: data)
        }.resume()
    }
    
    private func downloadMealImages() {
        DispatchQueue.main.async {
            self.mealsTableView.reloadData()
        }
        for imageIndexPair in imageURLs {
            downloadImageFromURL(URL(string: imageIndexPair.value), at: imageIndexPair.key)
        }
    }
    
}

extension DayDiaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        cell.delegate = self
        if let mealName = meals[indexPath.section]?.name {
            cell.recipe = meals[indexPath.section]
            cell.mealTypeLabel.text = mealName
        } else {
            cell.mealTypeLabel.text = mealTypes[indexPath.section]
        }
        
        if let mealCalories = meals[indexPath.section]?.calories {
            cell.caloriesLabel.text = "\(Int(mealCalories)) kcal"
        } else {
            cell.caloriesLabel.text = "Recomended: \(recomendedCalories[indexPath.section]) kcal"
        }
        cell.cellIndex = indexPath.section
        cell.mealImageView.image = chosenMealPhotos[indexPath.section]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationViewController = RecipeDetailViewController()
        destinationViewController.recipeFromParent = meals[indexPath.section]
        destinationViewController.image = chosenMealPhotos[indexPath.section]
        present(destinationViewController, animated: true, completion: nil)
    }
    
}

extension DayDiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedMealType = mealTypes.remove(at: indexPath.section)
            meals.removeValue(forKey: indexPath.section)
            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).updateData(["mealTypes":mealTypes])
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").document(removedMealType).delete()
            }
            
            tableView.beginUpdates()
            tableView.deleteSections([indexPath.section], with: .automatic)
            tableView.endUpdates()
            
            if let cell = tableView.cellForRow(at: indexPath) as? MealTableViewCell {
                let deletedCalories = Int(cell.recipe?.calories ?? 0)
                homeViewControllerDelegate?.todayCalories -= deletedCalories
                if let currentCalories = homeViewControllerDelegate?.allDaysCalories[weekday] {
                    homeViewControllerDelegate?.allDaysCalories[weekday] = currentCalories - deletedCalories
                }
            }
        }
    }
}

extension DayDiaryViewController: AddingNewMealDelegate {
    func getInfoForNewMeal(image: UIImage, calories: String, name: String) {
        mealTypes += [name]
        if let newMealTypes = dayDiaryModel.mealTypes {
            dayDiaryModel.mealTypes! += [name]
        }
        recomendedCalories += [calories]
        if let newCalories = dayDiaryModel.recomendedCalories {
            dayDiaryModel.recomendedCalories! += [calories]
        }
        defaultMealPhotos += [image]
        updateDBMealTypes()
        mealsTableView.reloadData()
    }
    
    func updateDBMealTypes() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).setData([
                "mealTypes":mealTypes,
                "recomendedCalories":recomendedCalories])
        }
    }
}

extension DayDiaryViewController: DataReloaderDelegate {
    func reloadInfo() {
        weekday = dayDiaryModel.weekday
        calendarLabel.text = weekday
        if let modelMealTypes = dayDiaryModel.mealTypes {
            mealTypes = modelMealTypes
        }
        if let modelRecomendedCalories = dayDiaryModel.recomendedCalories {
            recomendedCalories = modelRecomendedCalories
        }
        if let waterGlasses = dayDiaryModel.waterGlasses {
            self.homeViewControllerDelegate?.allDaysWaterGlasses[self.weekday] = waterGlasses
            if self.weekday == self.homeViewControllerDelegate?.currentPageWeekday {
                self.homeViewControllerDelegate?.userWaterGlasses = waterGlasses
            }
        }
        makeRequestForMeals()
    }
    
    func makeRequestForData() {
        makeRequestForMeals()
    }
}

extension DayDiaryViewController: TapReciverDelegate {
    func handleTap(for index: Int) {
        let destinationViewController = PickMealViewController()
        destinationViewController.delegate = self
        destinationViewController.pickMealModel.weekday = weekday
        destinationViewController.pickMealModel.mealType = mealTypes[index]
        present(destinationViewController, animated: true, completion: nil)
    }
}
