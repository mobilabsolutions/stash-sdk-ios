//
//  PaymentMethodType.swift
//  StashCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// PaymentMethodType: All payment method types that the SDK
/// currently supports
///
/// - creditCard: A credit card payment method
/// - sepa: A SEPA payment method
public enum PaymentMethodType: String {
    case creditCard
    case sepa
    case payPal
}

extension PaymentMethodType {
    /// Get the internal payment method type associated to the given payment method type
    var internalPaymentMethodType: InternalPaymentMethodType {
        switch self {
        case .creditCard:
            return .creditCard
        case .sepa:
            return .sepa
        case .payPal:
            return .payPal
        }
    }
}

extension PaymentMethodType: Codable {}
