//
//  PaymentProviderIntegrationBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge that allows using PaymentProviderIntegrations from Objective-C.
@objc(MLPaymentProviderIntegration) public class PaymentProviderIntegrationBridge: NSObject {
    let integration: PaymentProviderIntegration

    /// Create a new payment provider from a payment service provider as well as the payment method types that
    /// it should support.
    ///
    /// - Parameters:
    ///   - bridge: The payment provider bridge that should be used (and validated for use with the provided payment methods)
    ///   - paymentMethodTypes: The payment method types that this PSP should be used for (should be `PaymentMethodTypeBridge`s)
    @objc public init?(paymentServiceProvider bridge: PaymentProviderBridge, paymentMethodTypes: Set<Int>) {
        let paymentMethods = paymentMethodTypes.map { (method) -> PaymentMethodType in
            guard let bridgeType = PaymentMethodTypeBridge(rawValue: method),
                let type = bridgeType.paymentMethodType
            else { fatalError("Provided value (\(method)) does not correspond to a payment method") }
            return type
        }

        guard let integration = PaymentProviderIntegration(paymentServiceProvider: bridge.paymentProvider,
                                                           paymentMethodTypes: Set(paymentMethods))
        else { return nil }

        self.integration = integration
    }

    /// Create a new payment provider from a payment service provider
    ///
    /// - Parameters:
    ///   - bridge: The payment provider bridge that should be used
    @objc public init(paymentServiceProvider bridge: PaymentProviderBridge) {
        self.integration = PaymentProviderIntegration(paymentServiceProvider: bridge.paymentProvider)
    }
}
