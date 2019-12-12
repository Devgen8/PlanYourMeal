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
    var todayDate = Date()
    
    var userWaterGlasses: Int? {
        willSet {
            numberOfGlassesLabel.text = "\(newValue ?? 0)/\(userWaterGoal ?? 8)"
        }
    }
    var userWaterGoal: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUsersImage()
        getUsersImage()
        getUsersInfo()
        drawGlass()
        configurePageViewController()
        userWaterGlasses = 0
        userWaterGoal = 8
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        dailyCaloriesLabel.text = "0/2650"
        
        tickImageView.alpha = 0
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
    }
    
    func drawGlass() {
        let shape = CAShapeLayer()
        glassView.layer.addSublayer(shape)
        shape.lineWidth = 2
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = #colorLiteral(red: 0.6996294856, green: 0.930578053, blue: 0.9303538799, alpha: 1)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 45, y: 15))
        path.addLine(to: CGPoint(x: 45, y: 100))
        path.addLine(to: CGPoint(x: 75, y: 100))
        path.addLine(to: CGPoint(x: 75, y: 15))
        shape.path = path.cgPath
        let bottom = UIView(frame: CGRect(x: 44, y: 100, width: 33, height: 5))
        glassView.addSubview(bottom)
        bottom.backgroundColor = UIColor.white
        water = UIView(frame: CGRect(x: 45, y: 100, width: 30, height: 0))
        water?.backgroundColor = UIColor.blue
        glassView.addSubview(water!)
    }
    
    func fillGlass() {
        UIView.animate(withDuration: 1.5) {
            self.water?.frame.origin.y -= 10
            self.water?.frame.size.height += 10
        }
        UIView.animate(withDuration: 2) {
            self.numberOfGlassesLabel.transform = CGAffineTransform(scaleX: 4.0, y: 4.0)
            if self.userWaterGlasses != nil {
                self.userWaterGlasses! += 1
            }
            if self.userWaterGoal == self.userWaterGlasses {
                self.numberOfGlassesLabel.textColor = .systemGreen
            }
            self.numberOfGlassesLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func setUpUsersImage() {
        userImageView.layer.cornerRadius = 180
        userImageView.layer.borderWidth = 0.1
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        userImageView.isUserInteractionEnabled = true
        getUsersImage()
    }
    
    func getUsersImage() {
        if let userId = Auth.auth().currentUser?.uid {
            Storage.storage().reference().child("\(userId)").getData(maxSize: 1 * 2048 * 2048) { (data, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Error: can not get user image")
                    return
                }
                if let source = data {
                    self.userImageView.image = UIImage(data: source)
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
            fillGlass()
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
        return 3
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
    
    
}
