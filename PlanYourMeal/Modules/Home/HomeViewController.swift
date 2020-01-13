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
    
    private var water: UIView?
    private var currentViewControllerIndex = 0
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
    
    var allDaysCalories = [String:Int]()
    var todayCalories = 0 {
        willSet {
            dailyCaloriesLabel.text = "\(newValue)/\(User.dailyCalories ?? 1800) kcal"
            if let dayDiaryVC = currentDayDiaryViewController {
                homeModel.updateUsersCalories(with: newValue, for: dayDiaryVC.weekday)
            }
            if let selectedWeekday = currentDayDiaryViewController?.weekday {
                allDaysCalories[selectedWeekday] = newValue
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
                homeModel.updateUsersWaterGlasses(with: newValue, for: currentPageWeekday)
            }
        }
    }
    private var userWaterGoal = 8
    lazy var homeModel = HomeModel(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeModel.getDataFromDatabase()
        setUpUsersImage()
        drawGlass()
        configurePageViewController()
        setupNavigationBar()
        tickImageView.alpha = 0
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    private func configurePageViewController() {
        let mealsViewController = MealsPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        mealsViewController.delegate = self
        mealsViewController.dataSource = self
        addChild(mealsViewController)
        mealsViewController.didMove(toParent: self)
        mealsContentView.addSubview(mealsViewController.view)
        mealsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let views: [String : Any] = ["pageView" : mealsViewController.view as Any]
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
    
    private func drawGlass() {
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
    
    private func changeGlassView(withActivity activity: GlassActivityStatusPicker) {
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
    
    private func setUpUsersImage() {
        userImageView.layer.cornerRadius = 55
        userImageView.layer.borderWidth = 0.2
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        userImageView.isUserInteractionEnabled = true
    }
    
    @objc private func handlePickingPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
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
            if let uploadData = selectedImage.pngData() {
                homeModel.updatePhotoData(with: uploadData)
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
        currentIndex += 1
        currentViewControllerIndex = currentIndex
        return mealPageViewControllerAt(index: currentIndex)
    }
    
    func mealPageViewControllerAt(index: Int) -> DayDiaryViewController? {
        let dayDiaryViewController = DayDiaryViewController()
        dayDiaryViewController.positionInPages = index
        dayDiaryViewController.dayDiaryModel.dayOffset = index
        dayDiaryViewController.homeViewControllerDelegate = self
        return dayDiaryViewController
    }
}

extension HomeViewController: DataReloaderDelegate {
    func reloadInfo() {
        if let calories = homeModel.todayCalories {
            todayCalories = calories
        }
        if let sumCalories = homeModel.dailyCalories {
            self.dailyCaloriesLabel.text = "\(self.todayCalories)/\(sumCalories) kcal"
        }
        if let name = homeModel.usersName {
            userNameLabel.text = name
        }
    }
    
    func updateImageView(with image: UIImage) {
        userImageView.image = image
    }
}
