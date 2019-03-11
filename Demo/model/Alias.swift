//
//  Alias.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct Alias: Codable {
    let alias: String
    let expirationYear: Int?
    let expirationMonth: Int?
    let type: AliasType
}

enum AliasType: String, Codable {
    case creditCard
    case sepa
}
