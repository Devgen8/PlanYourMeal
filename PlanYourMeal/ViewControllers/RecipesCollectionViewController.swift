//
//  RecipesCollectionViewController.swift
//  PlanYourMeal
//
//  Created by мак on 10/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

final class RecipesCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "RecipeCell"
    
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
}

//extension RecipesCollectionViewController : UITextFieldDelegate {
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    // 1
//    let activityIndicator = UIActivityIndicatorView(style: .medium)
//    textField.addSubview(activityIndicator)
//    activityIndicator.frame = textField.bounds
//    activityIndicator.startAnimating()
//
//    flickr.searchFlickr(for: textField.text!) { searchResults in
//      activityIndicator.removeFromSuperview()
//
//      switch searchResults {
//      case .error(let error) :
//        // 2
//        print("Error Searching: \(error)")
//      case .results(let results):
//        // 3
//        print("Found \(results.searchResults.count) matching \(results.searchTerm)")
//        self.searches.insert(results, at: 0)
//        // 4
//        self.collectionView?.reloadData()
//      }
//    }
//
//    textField.text = nil
//    textField.resignFirstResponder()
//    return true
//  }
//}
