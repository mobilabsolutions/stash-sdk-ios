//
//  CreditCardType.swift
//  StashCore
//
//  Created by Robert on 28.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A type of credit card (or `.unknown` if the SDK was not able to determine a type)
public enum CreditCardType: String, CaseIterable {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case americanExpress = "AMEX"
    case diners = "DINERS"
    case discover = "DISCOVER"
    case jcb = "JCB"
    case maestroInternational = "MAESTRO"
    case chinaUnionPay = "UNIONPAY"
    case unknown = "UNKNOWN"
}

extension CreditCardType: Codable {}
