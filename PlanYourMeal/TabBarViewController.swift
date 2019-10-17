//
//  TabBarViewController.swift
//  PlanYourMeal
//
//  Created by мак on 09/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: .none, tag: 0)
        let recipesViewController = RecipesViewController()
        recipesViewController.tabBarItem = UITabBarItem(title: "Recipes", image: .none, tag: 1)
        let plusViewController = PlusViewController()
        plusViewController.tabBarItem = UITabBarItem(title: "+", image: .none, tag: 2)
        let shoppingListViewController = ShoppingListViewController()
        shoppingListViewController.tabBarItem = UITabBarItem(title: "Shopping list", image: .none, tag: 3)
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: .none, tag: 4)
        
        viewControllers = [homeViewController, recipesViewController, plusViewController, shoppingListViewController, profileViewController]
    }
}
