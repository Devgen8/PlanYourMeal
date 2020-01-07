//
//  ImageModel.swift
//  PlanYourMeal
//
//  Created by мак on 04/11/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import Foundation

class ImageModel {
    public var url: URL?
    let order: Int

    init(url: String?, order: Int) {
        self.url = url?.toURL
        self.order = order
    }
}

public extension String {
    var toURL: URL? {
        return URL(string: self)
    }
}
