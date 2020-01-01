//
//  TabBarViewController.swift
//  PlanYourMeal
//
//  Created by мак on 09/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

@objc class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        homeViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "house").withRenderingMode(.alwaysOriginal), tag: 0)
        homeViewController.navigationBar.topItem?.title = "Home"
        
        let recipesViewController = UINavigationController(rootViewController: RecipesViewController())
        recipesViewController.tabBarItem = UITabBarItem(title: "", image:  #imageLiteral(resourceName: "recipe").withRenderingMode(.alwaysOriginal), tag: 1)
        recipesViewController.navigationBar.topItem?.title = "Recipes"
        
        
        let shoppingListViewController = UINavigationController(rootViewController: ShoppingListViewController())
        shoppingListViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "checklist").withRenderingMode(.alwaysOriginal), tag: 3)
        shoppingListViewController.navigationBar.topItem?.title = "Shopping list"
        
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        profileViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "user").withRenderingMode(.alwaysOriginal), tag: 4)
        profileViewController.navigationBar.topItem?.title = "Profile"
        
        viewControllers = [homeViewController, recipesViewController, shoppingListViewController, profileViewController]
        
//        let backgroundImage = UIImage()
//        backgroundImage.withTintColor(.secondarySystemBackground)
        
        //tabBar.backgroundImage = backgroundImage
        tabBar.backgroundColor = .secondarySystemBackground
    }
}
