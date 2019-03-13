//
//  CreditCardTypeExtensions.swift
//  MobilabPaymentCore
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore

extension CreditCardData.CreditCardType {
    var bsCardTypeIdentifier: String? {
        switch self {
        case .visa: return "V"
        case .mastercard: return "M"
        case .americanExpress: return "A"
        case .diners: return "D"
        case .discover: return "D"
        case .jcb: return "J"
        case .maestroInternational: return "O"
        case .carteBleue: return "B"
        case .chinaUnionPay: return "P"
        case .unknown: return nil
        }
    }
}
