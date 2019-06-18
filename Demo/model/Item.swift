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
    let price: NSDecimalNumber
    var quantity: Int

    init(id: String, title: String, description: String?, picture: String?, price: NSDecimalNumber, quantity: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.picture = picture
        self.price = price
        self.quantity = quantity
    }

    init(item: Item, quantity: Int) {
        self.init(id: item.id, title: item.title, description: item.description, picture: item.picture, price: item.price, quantity: quantity)
    }
}
