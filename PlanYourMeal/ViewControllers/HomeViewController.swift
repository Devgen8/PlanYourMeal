//
//  HomeViewController.swift
//  PlanYourMeal
//
//  Created by мак on 09/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dailyCaloriesLabel: UILabel!
    @IBOutlet weak var numberOfGlassesLabel: UILabel!
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var addWaterButton: UIButton!
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var mealsContentView: UIView!
    
    var water: UIView?
    var currentViewControllerIndex = 0
    var currentDayDiaryViewController: DayDiaryViewController? {
        willSet {
            if let newCalories = allDaysCalories[newValue?.weekday ?? ""] {
                todayCalories = newCalories
            }
        }
    }
    var currentPageWeekday = "" {
        willSet {
            if let newCalories = allDaysCalories[newValue] {
                todayCalories = newCalories
            }
        }
        didSet {
            if let waterGlasses = allDaysWaterGlasses[self.currentPageWeekday] {
                userWaterGlasses = waterGlasses
            }
        }
    }
    var todayDate = Date()
    var weekday = ""
    var allDaysCalories = [String:Int]()
    var todayCalories = 0 {
        willSet {
            dailyCaloriesLabel.text = "\(newValue)/\(User.dailyCalories ?? 1800) kcal"
            if !allDaysCalories.values.contains(newValue) {
                if let userId = Auth.auth().currentUser?.uid, let dayDiaryVC = currentDayDiaryViewController {
                    Firestore.firestore().collection("users").document(userId).collection("Meals").document(dayDiaryVC.weekday).updateData(["todayCalories":newValue])
                }
                if let selectedWeekday = currentDayDiaryViewController?.weekday {
                    allDaysCalories[selectedWeekday] = newValue
                }
            }
        }
    }
    var allDaysWaterGlasses = [String:Int]()
    var userWaterGlasses = 0 {
        willSet {
            if newValue == userWaterGoal {
                tickImageView.alpha = 1
                addWaterButton.alpha = 0
                numberOfGlassesLabel.alpha = 0
            }
            if self.userWaterGlasses == userWaterGoal, newValue != userWaterGoal {
                tickImageView.alpha = 0
                addWaterButton.alpha = 1
                numberOfGlassesLabel.alpha = 1
            }
            let dayWaterDefference = newValue - self.userWaterGlasses
            if dayWaterDefference > 0 {
                for _ in stride(from: 0, to: dayWaterDefference, by: 1) {
                    self.changeGlassView(withActivity: .fill)
                }
            }
            if dayWaterDefference < 0 {
                for _ in stride(from: 0, to: -1 * dayWaterDefference, by: 1) {
                    self.changeGlassView(withActivity: .empty)
                }
            }
            numberOfGlassesLabel.text = "\(newValue)/\(userWaterGoal)"
            if allDaysWaterGlasses[currentPageWeekday] != nil,
                allDaysWaterGlasses[currentPageWeekday] != newValue {
                allDaysWaterGlasses[currentPageWeekday] = newValue
                if let userId = Auth.auth().currentUser?.uid {
                    Firestore.firestore().collection("users").document(userId).collection("Meals").document(currentPageWeekday).updateData(["waterGlassesNumber":newValue])
                }
            }
        }
    }
    var userWaterGoal = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGeneralUserInfo()
        setUpUsersImage()
        getUsersInfo()
        drawGlass()
        configurePageViewController()
        checkWaterInfo()
        setupNavigationBar()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        tickImageView.alpha = 0
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func checkWaterInfo() {
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
    
    func updateWaterInfo(for days: [String]) {
        for weekdayForUpdate in days {
            if let userId = Auth.auth().currentUser?.uid { Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekdayForUpdate).updateData(["waterGlassesNumber":0])
            }
        }
    }
    
    func getWeekdayName(with offset: Int) -> String? {
        var weekdayName: String?
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekdayName = dateFormatter.string(from: date)
        }
        return weekdayName
    }
    
    func getGeneralUserInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            if let date = Calendar.current.date(byAdding: .day, value: 0, to: todayDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                weekday = dateFormatter.string(from: date)
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekday).getDocument { [weak self] (snapshot, error) in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "Error: can not read data about allergens")
                        return
                    }
                    guard let `self` = self else { return }
                    if let caloriesForToday = snapshot?.data()?["todayCalories"] as? Int {
                        self.todayCalories = caloriesForToday
                    }
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
                    self.dailyCaloriesLabel.text = "\(self.todayCalories)/\(calories) kcal"
                } else {
                    self.calculateUsersDailyCalories()
                }
            }
        }
    }
    
    func calculateUsersDailyCalories() {
        
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
    
    func getUsersAge() {
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
    
    func getUsersBodyType() {
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
    
    func analizeUsersDataForCaloriesCalculation() {
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
        dailyCaloriesLabel.text = "\(todayCalories)/\(Int(calories))"
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("Additional info").document("Diet").setData(["dailyCalories":Int(calories)])
        }
    }
    
    func configurePageViewController() {
        let mealsViewController = MealsPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        mealsViewController.delegate = self
        mealsViewController.dataSource = self
        
        addChild(mealsViewController)
        mealsViewController.didMove(toParent: self)
        
        mealsContentView.addSubview(mealsViewController.view)
        
        mealsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String : Any] = ["pageView" : mealsViewController.view]

        mealsContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|",
                                                                       options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: views))

        mealsContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: views))
        
        
        
        guard let startingViewController = mealPageViewControllerAt(index: currentViewControllerIndex) else {
            return
        }
        
        mealsViewController.setViewControllers([startingViewController], direction: .forward, animated: true)
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [MealsPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.label
        appearance.currentPageIndicatorTintColor = UIColor.systemGreen
    }
    
    func drawGlass() {
        let shape = CAShapeLayer()
        glassView.layer.addSublayer(shape)
        shape.lineWidth = 2
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = #colorLiteral(red: 0.8516064547, green: 0.9619499025, blue: 1, alpha: 1)
        shape.fillColor = #colorLiteral(red: 0.6996294856, green: 0.930578053, blue: 0.9303538799, alpha: 1)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 15, y: 10))
        path.addLine(to: CGPoint(x: 15, y: 95))
        path.addLine(to: CGPoint(x: 45, y: 95))
        path.addLine(to: CGPoint(x: 45, y: 10))
        shape.path = path.cgPath
        let bottom = UIView(frame: CGRect(x: 13, y: 95, width: 34, height: 5))
        glassView.addSubview(bottom)
        bottom.backgroundColor = #colorLiteral(red: 0.8516064547, green: 0.9619499025, blue: 1, alpha: 1)
        water = UIView(frame: CGRect(x: 15, y: 95, width: 30, height: 0))
        water?.backgroundColor = UIColor.blue
        glassView.addSubview(water!)
    }
    
    func changeGlassView(withActivity activity: GlassActivityStatusPicker) {
        UIView.animate(withDuration: 1.5) {
            if activity == .fill {
                self.water?.frame.origin.y -= 10
                self.water?.frame.size.height += 10
            } else {
                self.water?.frame.origin.y += 10
                self.water?.frame.size.height -= 10
            }
        }
        if activity == .fill {
            UIView.animate(withDuration: 1.5) {
                self.numberOfGlassesLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                if self.userWaterGoal == self.userWaterGlasses {
                    self.numberOfGlassesLabel.textColor = .systemGreen
                }
                self.numberOfGlassesLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func setUpUsersImage() {
        userImageView.layer.cornerRadius = 55
        userImageView.layer.borderWidth = 0.2
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        userImageView.isUserInteractionEnabled = true
        getUsersImage()
    }
    
    func getUsersImage() {
        if let userId = Auth.auth().currentUser?.uid {
            Storage.storage().reference().child("\(userId)").getData(maxSize: 1 * 4048 * 4048) { (data, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not get user image")
                    return
                }
                if let source = data {
                    
                    let downloadImage = UIImage(data: source)
                    self.userImageView.image = downloadImage
                }
            }
        }
    }
    
    @objc func handlePickingPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func getUsersInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document("\(userId)").getDocument { [weak self] (document, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not get users name")
                    return
                }
                if let name = document?.data()?["name"] as? String {
                    self?.userNameLabel.text = name
                }
            }
        }
    }
   
    @IBAction func addWaterTapped(_ sender: UIButton) {
        if userWaterGlasses != userWaterGoal {
            userWaterGlasses += 1
        }
        if userWaterGlasses == userWaterGoal {
            UIView.animate(withDuration: 2, delay: 2, options: [], animations: {
                self.addWaterButton.alpha -= 1
                self.numberOfGlassesLabel.alpha -= 1
            }, completion: nil)
            UIView.animate(withDuration: 3, delay: 3, options: [], animations: {
                self.tickImageView.alpha += 1
                self.tickImageView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                self.tickImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
    }
    
    func mealPageViewControllerAt(index: Int) -> DayDiaryViewController? {
        let dayDiaryViewController = DayDiaryViewController()
        dayDiaryViewController.positionInPages = index
        dayDiaryViewController.homeViewControllerDelegate = self
        
        return dayDiaryViewController
    }
}

extension HomeViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            userImageView.image = selectedImage
            let uploadData = selectedImage.pngData()!
            if let userId = Auth.auth().currentUser?.uid {
                Storage.storage().reference().child("\(userId)").putData(uploadData)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension HomeViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 7
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let dayDiaryViewController = viewController as? DayDiaryViewController
        
        guard var currentIndex = dayDiaryViewController?.positionInPages else {
            return nil
        }
        
        if currentIndex == 0 {
            return nil
        }
        
//        let weekdayOfCalories = getWeekdayName(with: currentIndex)
//        checkCaloriesNumber(in: weekdayOfCalories ?? "")
        
        currentIndex -= 1
        
        currentViewControllerIndex = currentIndex
        
        
        return mealPageViewControllerAt(index: currentIndex)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let dayDiaryViewController = viewController as? DayDiaryViewController
        
        guard var currentIndex = dayDiaryViewController?.positionInPages else {
            return nil
        }
        
        if currentIndex == 6 {
            return nil
        }
        
//        let weekdayOfCalories = getWeekdayName(with: currentIndex)
//        checkCaloriesNumber(in: weekdayOfCalories ?? "")
        
        currentIndex += 1
        
        currentViewControllerIndex = currentIndex
        
        return mealPageViewControllerAt(index: currentIndex)
    }
    
    func checkCaloriesNumber(in weekdayOfVC: String) {
        if allDaysCalories[weekdayOfVC] == nil {
            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(userId).collection("Meals").document(weekdayOfVC).getDocument { [weak self] (snapshot, error) in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "Error: can not read data about allergens")
                        return
                    }
                    guard let `self` = self else { return }
                    if let calories = snapshot?.data()?["todayCalories"] as? Int {
                        self.allDaysCalories[weekdayOfVC] = calories
                        DispatchQueue.main.async {
                            self.todayCalories = calories
                        }
                    } else {
                        self.allDaysCalories[weekdayOfVC] = 0
                        DispatchQueue.main.async {
                            self.todayCalories = 0
                        }
                    }
                }
            }
        }
    }
    
}
