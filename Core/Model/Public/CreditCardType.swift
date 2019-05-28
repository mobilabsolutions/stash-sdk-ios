//
//  CreditCardType.swift
//  MobilabPaymentCore
//
//  Created by Robert on 28.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public enum CreditCardType: String, CaseIterable {
    case visa = "VISA"
    case mastercard = "MASTER_CARD"
    case americanExpress = "AMEX"
    case diners = "DINERS"
    case discover = "DISCOVER"
    case jcb = "JCB"
    case maestroInternational = "MAESTRO"
    case chinaUnionPay = "UNIONPAY"
    case unknown = "UNKNOWN"
}

extension CreditCardType: Codable {}
