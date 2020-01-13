//
//  RecipesViewController.swift
//  PlanYourMeal
//
//  Created by мак on 16/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class RecipesViewController: UIViewController {
    
    private let networkDataFetcher = NetworkDataFetcher()
    private var searchResponse: SearchResponse? = nil
    private var timer: Timer?
    private let searchController = UISearchController(searchResultsController: nil)
    private var loadingOperation = [IndexPath: DataLoadOperation]()
    private var loadingQueue = OperationQueue()
    private var cachedImages : [IndexPath: UIImage]?
    private var arrayOfStrings = [String]()
    var recipesModel = RecipesModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        loadingIndicator.hidesWhenStopped = true
        setupSearchBar()
        let nibCell = UINib(nibName: "RecipeCollectionViewCell", bundle: nil)
        collectionView.register(nibCell, forCellWithReuseIdentifier: "RecipeCollectionViewCell")
        
        //cells layout setting
        collectionView.collectionViewLayout = Design.getCellsLayout()
        setupNavigationBar()
        collectionView.reloadData()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self as UISearchBarDelegate
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
}

//MARK: Prefetching
extension RecipesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperation[indexPath] { return }
            if let dataLoader = loadImage(at: indexPath.row) {
                loadingQueue.addOperation(dataLoader)
                loadingOperation[indexPath] = dataLoader
            }
        }
    }
    
    func loadImage(at index: Int) -> DataLoadOperation? {
        if searchResponse?.hits?.indices.contains(index) ?? false, let image = searchResponse?.hits?[index].recipe?.image {
            return DataLoadOperation(image)
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperation[indexPath] {
                dataLoader.cancel()
                loadingOperation.removeValue(forKey: indexPath)
            }
        }
    }
}

//MARK: CollectionViewDataSource
extension RecipesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResponse?.hits?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCollectionViewCell", for: indexPath) as! RecipeCollectionViewCell
        let recipe = searchResponse?.hits?[indexPath.row]
        cell.nameOfrecipe.text = recipe?.recipe?.label
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        cell.tag = indexPath.row;
        cell.updateAppearanceFor(self.cachedImages?[indexPath])
        return cell
    }
}

//MARK: CollectionViewDelegate
extension RecipesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeDetailViewController = RecipeDetailViewController()
        if let selectedRecipe = searchResponse?.hits?[indexPath.row].recipe {
            var recipeForDestVC = MealDataModel(name: selectedRecipe.label, calories: (selectedRecipe.calories ?? 0)/10, url: selectedRecipe.url)
            let (ingredientNames, ingredientWeights) = recipesModel.getIngredientNames(for: indexPath.row)
            recipeForDestVC.ingredientNames = ingredientNames
            recipeForDestVC.ingredientWeights = ingredientWeights
            recipeDetailViewController.recipeFromParent = recipeForDestVC
        }
        recipeDetailViewController.image = self.cachedImages?[indexPath]
        self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? RecipeCollectionViewCell else { return }

        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            if cell.tag == indexPath.row {
                cell.updateAppearanceFor(image)
            }
            self.loadingOperation.removeValue(forKey: indexPath)
            self.cachedImages?[indexPath] = image
        }

        if let dataLoader = loadingOperation[indexPath] {
            if let image = dataLoader.image {
                cell.updateAppearanceFor(image)
                loadingOperation.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompletionHandler = updateCellClosure
            }
        } else {
            if let dataLoader = loadImage(at: indexPath.row) {
                dataLoader.loadingCompletionHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperation[indexPath] = dataLoader
            }
        }
    }
}

//MARK: Search Bar Delegate
extension RecipesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cachedImages = nil
        cachedImages = [IndexPath: UIImage]()
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        self.collectionView.isHidden = true
        self.hintLabel.isHidden = true
        if searchText != "" {
            let editedString = searchText.replacingOccurrences(of: " ", with: "%20")
            let urlString = NetworkingService.getUserRelatedUrlString(with: editedString)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                self.networkDataFetcher.fetchRecipes(urlString: urlString) { (searchResponse) in
                    guard let searchResponse = searchResponse else { return }
                    self.searchResponse = searchResponse
                    self.recipesModel.searchResponse = searchResponse
                    self.collectionView.isHidden = true
                    self.loadingIndicator.isHidden = false
                    self.loadingIndicator.startAnimating()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    self.hintLabel.isHidden = true
                }
            })
        }
        if searchText == "" {
            loadingIndicator.stopAnimating()
            collectionView.isHidden = true
            hintLabel.isHidden = false
        }
    }
}
