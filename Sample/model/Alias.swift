//
//  Alias.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct Alias: Codable {
    let alias: String
    let humanReadableId: String?
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