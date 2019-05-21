//
//  Item.swift
//  Demo
//
//  Created by Rupali Ghate on 20.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct Item {
    let id: String
    let title: String
    let description: String?
    let picture: String?
    let price: Float
    let currency: String

    init(title: String, description: String?, picture: String?, price: Float, currency: String = "€") {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.picture = picture
        self.price = price
        self.currency = currency
    }
}
