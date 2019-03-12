//
//  AliasExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum PaymentMethod: String, Codable {
    case creditCard = "CC"
    case sepa = "SEPA"
    case payPal = "PAY_ PAL"
    case googlePay = "GOOGLE_PAY"
    case applePay = "APPLE_PAY"
    case klarna = "KLARNA"
}

struct AliasExtra: Codable {
    let ccExpiry: String
    let ccMask: String
    let ccType: String
    let email: String
    let ibanMask: String
    let paymentMethod: PaymentMethod
}
