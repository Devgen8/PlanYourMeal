//
//  DataLoadOperation.swift
//  PlanYourMeal
//
//  Created by мак on 04/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation
import UIKit

class DataLoadOperation: Operation {
    var image: UIImage?
    var loadingCompletionHandler: ((UIImage?) -> ())?
    private var _image: URL?
    init(_ image: String) {
        _image = URL(string: image)
    }

    override func main() {
        if isCancelled { return }
        guard let url = _image else { return }
        downloadImageFromURL(url) { (image) in
            DispatchQueue.main.async() { [weak self] in
                guard let `self` = self else { return }
                if self.isCancelled { return }
                self.image = image
                self.loadingCompletionHandler?(self.image)
            }
        }
    }
}

func downloadImageFromURL(_ url: URL, completionHandler: @escaping (UIImage?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let newImage = UIImage(data: data)
            else { return }
        completionHandler(newImage)
    }.resume()
}
