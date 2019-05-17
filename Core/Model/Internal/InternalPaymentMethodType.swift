//
//  InternalPaymentMethodType.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum InternalPaymentMethodType: String, Codable {
    case creditCard = "CC"
    case sepa = "SEPA"
    case payPal = "PAY_PAL"
    case googlePay = "GOOGLE_PAY"
    case applePay = "APPLE_PAY"
    case klarna = "KLARNA"
}

extension InternalPaymentMethodType {
    var publicPaymentMethodType: PaymentMethodType? {
        switch self {
        case .creditCard: return .creditCard
        case .sepa: return .sepa
        case .payPal: return .payPal
        default: return nil
        }
    }
}
