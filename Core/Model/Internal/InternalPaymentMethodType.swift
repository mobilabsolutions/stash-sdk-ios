//
//  NetworkingPaymentMethodType.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum InternalPaymentMethodType: String, Codable {
    case creditCard = "CC"
    case sepa = "SEPA"
    case payPal = "PAY_ PAL"
    case googlePay = "GOOGLE_PAY"
    case applePay = "APPLE_PAY"
    case klarna = "KLARNA"
}
