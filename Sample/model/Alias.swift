//
//  Alias.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

struct Alias: Codable {
    let alias: String
    let extraInfo: String?
    let expirationYear: Int?
    let expirationMonth: Int?
    let type: AliasType
}

enum AliasType: String, Codable {
    case creditCard
    case sepa
    case payPal
    case unknown

    init(paymentMethodType: PaymentMethodType) {
        switch paymentMethodType {
        case .creditCard: self = .creditCard
        case .sepa: self = .sepa
        case .payPal: self = .payPal
        }
    }
}
