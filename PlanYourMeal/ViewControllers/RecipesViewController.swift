//
//  RecipesViewController.swift
//  PlanYourMeal
//
//  Created by мак on 16/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class RecipesViewController: UIViewController {
    
    let networkDataFetcher = NetworkDataFetcher()
    var searchResponse: SearchResponse? = nil
    private var timer: Timer?
    let searchController = UISearchController(searchResultsController: nil)
    private var loadingOperation = [IndexPath: DataLoadOperation]()
    private var loadingQueue = OperationQueue()
    private var cachedImages : [IndexPath: UIImage]?
    let defaultPhoto = "https://www.google.com/search?biw=1440&bih=821&tbm=isch&sa=1&ei=KpqsXYD9IMHnmwXmxr7wCw&q=food&oq=food&gs_l=img.3..0i67j0j0i67l3j0l3j0i67l2.11046.12432..12745...0.0..1.364.716.7j3-1......0....1..gws-wiz-img.....0..0i131.qRMKa9uP2Mc&ved=0ahUKEwiAuo6br6vlAhXB86YKHWajD74Q4dUDCAc&uact=5#imgrc=DOALplamMwZj5M:"
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrayOfStrings = [String]()
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
        
        collectionView.reloadData()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self as UISearchBarDelegate
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func loadImage(at index: Int) -> DataLoadOperation? {
        if (searchResponse?.hits?.indices.contains(index))! {
            return DataLoadOperation(searchResponse?.hits?[index].recipe!.image ?? defaultPhoto)
        }
        return nil
    }
}

//MARK: Prefetching
extension RecipesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("\(indexPaths)")
        for indexPath in indexPaths {
            if let _ = loadingOperation[indexPath] { return }
            if let dataLoader = loadImage(at: indexPath.row) {
                loadingQueue.addOperation(dataLoader)
                loadingOperation[indexPath] = dataLoader
            }
        }
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
        recipeDetailViewController.recipeFromCollectionView = searchResponse?.hits?[indexPath.row].recipe
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cachedImages = nil
        cachedImages = [IndexPath: UIImage]()
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        self.collectionView.isHidden = true
        let urlString = "https://api.edamam.com/search?q=\(searchText)&app_id=a5d31602&app_key=77acb77520745ac6c97ca539e8b612cb"
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkDataFetcher.fetchRecipes(urlString: urlString) { (searchResponse) in
                guard let searchResponse = searchResponse else { return }
                self.searchResponse = searchResponse
                self.collectionView.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
            }
        })
        if searchText == "" {
            loadingIndicator.stopAnimating()
            collectionView.isHidden = true
        }
    }
}
