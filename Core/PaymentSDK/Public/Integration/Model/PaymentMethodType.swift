//
//  PaymentMethodType.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

/// PaymentMethodType: All payment method types that the SDK
/// currently supports
///
/// - creditCard: A credit card payment method
/// - sepa: A SEPA payment method
public enum PaymentMethodType {
    case creditCard
    case sepa
    case payPal
}

extension PaymentMethodType {
    /// Get the internal payment method type associated to the given payment method type
    init?(value: String) {
        switch value {
        case "creditCard":
            self = .creditCard
        case "sepa":
            self = .sepa
        case "payPal":
            self = .payPal
        default:
            return nil
        }
    }
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
