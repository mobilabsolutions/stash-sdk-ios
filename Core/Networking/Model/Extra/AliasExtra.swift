//
//  AliasExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct AliasExtra: Codable {
    let ccConfig: CreditCardExtra?
    let sepaConfig: SepaExtra?
    let payPalConfig: PayPalExtra?
    let paymentMethod: InternalPaymentMethodType

    init(ccConfig: CreditCardExtra) {
        self.paymentMethod = .creditCard
        self.ccConfig = ccConfig
        self.sepaConfig = nil
        self.payPalConfig = nil
    }

    init(sepaConfig: SepaExtra) {
        self.paymentMethod = .sepa
        self.sepaConfig = sepaConfig
        self.ccConfig = nil
        self.payPalConfig = nil
    }

    init(payPalConfig: PayPalExtra) {
        self.paymentMethod = .payPal
        self.payPalConfig = payPalConfig
        self.ccConfig = nil
        self.sepaConfig = nil
    }
}

struct CreditCardExtra: Codable {
    let ccExpiry: String
    let ccMask: Int
    let ccType: String
}

struct SepaExtra: Codable {
    let iban: String
    let bic: String?
    let name: String?
    let email: String?
    let street: String?
    let country: String?
    let zip: String?
}

struct PayPalExtra: Codable {}
