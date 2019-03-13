//
//  AliasExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum PaymentMethodType: String, Codable {
    case creditCard = "CC"
    case sepa = "SEPA"
    case payPal = "PAY_ PAL"
    case googlePay = "GOOGLE_PAY"
    case applePay = "APPLE_PAY"
    case klarna = "KLARNA"
}

struct AliasExtra: Codable {
    let ccConfig: CreditCardExtra?
    let sepaConfig: SepaExtra?
    let paymentMethod: PaymentMethodType

    init(ccConfig: CreditCardExtra) {
        self.paymentMethod = .creditCard
        self.ccConfig = ccConfig
        self.sepaConfig = nil
    }

    init(sepaConfig: SepaExtra) {
        self.paymentMethod = .sepa
        self.sepaConfig = sepaConfig
        self.ccConfig = nil
    }
}

struct CreditCardExtra: Codable {
    let ccExpiry: String
    let ccMask: Int
    let ccType: String
}

struct SepaExtra: Codable {
    let iban: String
    let bic: String
    let name: String?
    let email: String?
    let street: String?
    let country: String?
    let zip: String?
}
