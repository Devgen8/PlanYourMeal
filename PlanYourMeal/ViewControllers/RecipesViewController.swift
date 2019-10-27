//
//  RecipesViewController.swift
//  PlanYourMeal
//
//  Created by мак on 16/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit

class RecipesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let networkDataFetcher = NetworkDataFetcher()
    var searchResponse: SearchResponse? = nil
    private var timer: Timer?
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrayOfStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
        
        setupSearchBar()
        
        let nibCell = UINib(nibName: "RecipeCollectionViewCell", bundle: nil)
        collectionView.register(nibCell, forCellWithReuseIdentifier: "RecipeCollectionViewCell")
        
        let itemSize = UIScreen.main.bounds.width/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        collectionView.collectionViewLayout = layout
        
        collectionView.reloadData()
    }
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self as UISearchBarDelegate
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResponse?.hits?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCollectionViewCell", for: indexPath) as! RecipeCollectionViewCell
        let recipe = searchResponse?.hits?[indexPath.row]
        cell.nameOfrecipe.text = recipe?.recipe?.label
        cell.image.image = preparePhoto(at: indexPath.row)
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeDetailViewController = RecipeDetailViewController()
        recipeDetailViewController.recipeFromCollectionView = searchResponse?.hits?[indexPath.row].recipe
        recipeDetailViewController.image = preparePhoto(at: indexPath.row)
        self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
    }
    
    func preparePhoto(at position: Int) -> UIImage? {
        var image: UIImage?
        if let imageUrl = URL(string: searchResponse?.hits?[position].recipe?.image ?? "https://www.google.com/search?biw=1440&bih=821&tbm=isch&sa=1&ei=KpqsXYD9IMHnmwXmxr7wCw&q=food&oq=food&gs_l=img.3..0i67j0j0i67l3j0l3j0i67l2.11046.12432..12745...0.0..1.364.716.7j3-1......0....1..gws-wiz-img.....0..0i131.qRMKa9uP2Mc&ved=0ahUKEwiAuo6br6vlAhXB86YKHWajD74Q4dUDCAc&uact=5#imgrc=DOALplamMwZj5M:") {
            do {
                let data = try Data(contentsOf: imageUrl)
                image = UIImage(data: data)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        return image
    }
}

extension RecipesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        let urlString = "https://api.edamam.com/search?q=\(searchText)&app_id=$8970fa60&app_key=$6cc2c40707ad312d2be3037bc7c3e7a7"
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkDataFetcher.fetchRecipes(urlString: urlString) { (searchResponse) in
                guard let searchResponse = searchResponse else { return }
                self.searchResponse = searchResponse
                self.collectionView.reloadData()
            }
        })
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        if searchText == "" { loadingIndicator.stopAnimating() }
    }
}
