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
    var mealTypes = [String]()
    var defaultMealPhotos = [#imageLiteral(resourceName: "Breakfast"), #imageLiteral(resourceName: "Lunch"), #imageLiteral(resourceName: "Dinner-1"), #imageLiteral(resourceName: "Snack")]
    var recomendedCalories = [String]()
    var calendar = Calendar.current
    var todayDate = Date()
    var weekday = ""
    var meals = [Int:MealDataModel]()
    var mealRecipes = [Int:Recipe]()
    var chosenMealPhotos = [Int:UIImage]()
    var imageURLs = [Int:String]()
    var homeViewControllerDelegate: HomeViewController?
    let networkDataFetcher = NetworkDataFetcher()
    @IBOutlet weak var newMealButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        getWeekdayMealTypes()
        activityIndicator.hidesWhenStopped = true
        //makeRequestForMeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeViewControllerDelegate?.currentPageWeekday = weekday
    }
    
    func getWeekdayMealTypes() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).getDocument { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not read meal types info")
                    return
                }
                self.mealTypes = snapshot?.data()?["mealTypes"] as? [String] ?? [String]()
                self.recomendedCalories = snapshot?.data()?["recomendedCalories"] as? [String] ?? [String]()
                if let waterGlasses = snapshot?.data()?["waterGlassesNumber"] as? Int {
                    self.homeViewControllerDelegate?.allDaysWaterGlasses[self.weekday] = waterGlasses
                    if self.weekday == self.homeViewControllerDelegate?.currentPageWeekday {
                        self.homeViewControllerDelegate?.userWaterGlasses = waterGlasses
                    }
                }
                self.makeRequestForMeals()
            }
        }
    }
    
    @IBAction func newMealTapped(_ sender: UIButton) {
        var destinationViewController = AddingMealTypeViewController()
        destinationViewController.delegate = self
        present(destinationViewController, animated: true, completion: nil)
    }
    
    @IBAction func autoPickFoodTapped(_ sender: UIButton) {
        mealsTableView.isHidden = true
        activityIndicator.startAnimating()
        var indexOfMeal = 0
        //var totalCalories = 0
        for mealType in mealTypes {
            print(mealType)
            let letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "v"]
            let randomLetter = letters[Int.random(in: 0..<letters.count)]
            let urlString = getUserRelatedUrlString(withText: randomLetter, calories: recomendedCalories[indexOfMeal])
            networkDataFetcher.fetchRecipes(urlString: urlString) { [weak self] (searchResponse) in
                var pickedMeal = MealDataModel()
                guard searchResponse != nil else {
                    return
                }
                if let numberOfRecipes = searchResponse?.hits?.count, numberOfRecipes != 0 {
                    let randomNumber = Int.random(in: 0..<numberOfRecipes)
                    let randomRecipe = searchResponse?.hits?[randomNumber].recipe
                    if let recipe = randomRecipe {
                        if let userId = Auth.auth().currentUser?.uid {
                            var ingredientNames = [String]()
                            var ingredientWeights = [Float]()
                            var ingredientStatus = [Bool]()
                            for ingredient in (recipe.ingredients ?? [Ingredient()]) {
                                ingredientNames.append(ingredient.text ?? "")
                                ingredientWeights.append(ingredient.weight ?? 0)
                                ingredientStatus.append(false)
                            }
                            Firestore.firestore().collection("users").document(userId).collection("Meals").document(self?.weekday ?? "").collection("MealTypes").document("\(mealType)").setData([
                            "calories":(recipe.calories ?? 0)/10,
                            "image":recipe.image ?? "",
                            "ingredientNames":ingredientNames,
                            "ingredientWeights":ingredientWeights,
                            "ingredientStatus":ingredientStatus,
                            "name":recipe.label ?? "",
                            "mealType":mealType,
                            "url":recipe.url ?? ""])
                            self?.mealRecipes[indexOfMeal] = recipe
                            indexOfMeal += 1
                            //totalCalories += Int(recipe.calories ?? 0)
                            if indexOfMeal + 1 == mealType.count {
//                                if let delegate = self?.homeViewControllerDelegate, let `self` = self {
//                                    delegate.allDaysCalories[self.weekday] = totalCalories
//                                }
                                self?.activityIndicator.stopAnimating()
                                self?.mealsTableView.isHidden = false
                                self?.makeRequestForMeals()
                            }
                        }
//                        pickedMeal.calories = recipe.calories
//                        pickedMeal.image = recipe.image
//                        pickedMeal.name = recipe.label
                    }
//                    self?.meals[indexOfMeal] = pickedMeal
//                    if let photo = pickedMeal.image {
//                        self?.downloadImageFromURL(URL(string: photo), at: indexOfMeal)
//                    } else {
//                        self?.chosenMealPhotos[indexOfMeal] = self?.defaultMealPhotos[indexOfMeal]
//                    }
                }
                //self?.mealsTableView.reloadData()
            }
        }
    }
    
    func getUserRelatedUrlString(withText editedString: String, calories: String) -> String {
        var healthParameters: [String]?
        var healthParametersJoined: String?
        if let diet = User.dietType {
            healthParameters = [diet]
        }
        if let allergens = User.allergensInfo {
            healthParameters = healthParameters != nil ? healthParameters ?? [] + allergens : allergens
        }
        healthParametersJoined = healthParameters?.joined(separator: "&health=")
        if let joinedString = healthParametersJoined{
            healthParametersJoined = "&health=" + joinedString
        }
        let urlString = "https://api.edamam.com/search?q=\(editedString)&app_id=a5d31602&app_key=77acb77520745ac6c97ca539e8b612cb&calories=\(calories)\(healthParametersJoined ?? "&diet=balanced")"
        return urlString
    }
    
    func makeRequestForMeals() {
        var totalCalories = 0
        meals = [Int:MealDataModel]()
        if let userId = Auth.auth().currentUser?.uid {
            print(userId)
            Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).collection("MealTypes").getDocuments { [weak self] (snapshot, error) in
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
                            //self?.imageURLs[indexOfMeal] = photo
                            //self?.mealsTableView.reloadData()
                        } else {
                            self.chosenMealPhotos[indexOfMeal] = self.defaultMealPhotos[indexOfMeal]
                        }
                        //self?.mealsTableView.reloadData()
                    }
                    self.mealsTableView.reloadData()
                    //self?.downloadMealImages()
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
            DispatchQueue.main.async {
                self?.mealsTableView.reloadData()
            }
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
        return 110
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
        recomendedCalories += [calories]
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
        makeRequestForMeals()
    }
}

extension DayDiaryViewController: TapReciverDelegate {
    func handleTap(for index: Int) {
        let destinationViewController = PickMealViewController()
        destinationViewController.delegate = self
        destinationViewController.weekday = weekday
        destinationViewController.mealType = mealTypes[index]
        present(destinationViewController, animated: true, completion: nil)
    }
}
