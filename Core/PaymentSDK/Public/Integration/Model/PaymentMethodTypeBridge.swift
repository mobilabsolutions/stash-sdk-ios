//
//  PaymentMethodTypeBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge that allows usage of PaymentMethodTypes from Objective-C
@objc(MLPaymentMethodType) public enum PaymentMethodTypeBridge: Int {
    case none = 0
    case creditCard
    case payPal
    case sepa

    /// The corresponding Swift payment method type (nil if `none`)
    public var paymentMethodType: PaymentMethodType? {
        switch self {
        case .none: return nil
        case .creditCard: return .creditCard
        case .payPal: return .payPal
        case .sepa: return .sepa
        }
    }
}
