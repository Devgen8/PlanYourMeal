//
//  NetworkDataFetcher.swift
//  PlanYourMeal
//
//  Created by мак on 20/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation

class NetworkDataFetcher {
    
    let networkReader = NetworkReader()
    
    func fetchRecipes(urlString: String, response: @escaping (SearchResponse?) -> Void) {
        networkReader.request(urlString: urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let recipes = try JSONDecoder().decode(SearchResponse.self, from: data)
                    response(recipes)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    response(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
        }
    }
}
