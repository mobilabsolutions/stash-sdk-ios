//
//  PaymentProviderIntegration.swift
//  StashCore
//
//  Created by Robert on 28.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// An integration of a payment service provider for a set of payment method types
public struct PaymentProviderIntegration {
    /// The payment service provider that will be integrated
    public let paymentServiceProvider: PaymentServiceProvider
    /// The payment method types for which the payment service provider should be used
    public let paymentMethodTypes: Set<PaymentMethodType>

    /// Create a payment provider integration with select payment method types.
    ///
    /// - Parameters:
    ///   - paymentServiceProvider: The payment service provider that should be integrated
    ///   - paymentMethodTypes: The payment method types for whicht this provider should be used.
    ///                         If the payment service provider does not support the given method types, return nil.
    public init?(paymentServiceProvider: PaymentServiceProvider, paymentMethodTypes: Set<PaymentMethodType>) {
        guard paymentMethodTypes.subtracting(Set(paymentServiceProvider.supportedPaymentMethodTypes)).isEmpty else {
            return nil
        }

        self.paymentMethodTypes = paymentMethodTypes
        self.paymentServiceProvider = paymentServiceProvider
    }

    /// Create a payment provider integration with all supported payment method types.
    ///
    /// - Parameter paymentServiceProvider: The payment service provider that should be integrated
    public init(paymentServiceProvider: PaymentServiceProvider) {
        self.paymentServiceProvider = paymentServiceProvider
        self.paymentMethodTypes = Set(paymentServiceProvider.supportedPaymentMethodTypes)
    }
}
