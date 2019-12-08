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
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: .none, tag: 0)
        homeViewController.navigationBar.topItem?.title = "Home"
        
        let recipesViewController = UINavigationController(rootViewController: RecipesViewController())
        recipesViewController.tabBarItem = UITabBarItem(title: "Recipes", image: .none, tag: 1)
        recipesViewController.navigationBar.topItem?.title = "Recipes"
        
        let plusViewController = PlusViewController()
        plusViewController.tabBarItem = UITabBarItem(title: "+", image: .none, tag: 2)
        
        let shoppingListViewController = UINavigationController(rootViewController: ShoppingListViewController())
        shoppingListViewController.tabBarItem = UITabBarItem(title: "Shopping list", image: .none, tag: 3)
        shoppingListViewController.navigationBar.topItem?.title = "Shopping list"
        
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: .none, tag: 4)
        profileViewController.navigationBar.topItem?.title = "Profile"
        
        viewControllers = [homeViewController, recipesViewController, plusViewController, shoppingListViewController, profileViewController]
        
        let backgroundImage = UIImage()
        backgroundImage.withTintColor(.clear)
        
        tabBar.backgroundImage = backgroundImage
    }
}
