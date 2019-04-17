//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public typealias RegistrationResult = Result<String, MobilabPaymentError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

public class MobilabPaymentSDK {
    /// Configure the SDK
    ///
    /// - Parameter configuration: The configuration to use for subsequent operations
    public static func configure(configuration: MobilabPaymentConfiguration) {
        InternalPaymentSDK.sharedInstance.configure(configuration: configuration)
    }

    /// Configure the SDK's UI
    ///
    /// - Parameter configuration: The configuration to apply to the presented UI
    public static func configureUI(configuration: PaymentMethodUIConfiguration) {
        InternalPaymentSDK.sharedInstance.configureUI(configuration: configuration)
    }

    /// Register payment service provider to be used for registering supplied payment method types
    ///
    /// - Parameter provider: The payment service provider module to register
    /// - Parameter paymentMethodTypes: Payment method types that will use selected provider
    public static func registerProvider(provider: PaymentServiceProvider, forPaymentMethodTypes paymentMethodTypes: PaymentMethodType...) {
        InternalPaymentSDK.sharedInstance.registerProvider(provider: provider, forPaymentMethodTypes: paymentMethodTypes)
    }

    /// Create a registration manager to use for registering payment methods
    ///
    /// - Returns: The registration manager
    public static func getRegistrationManager() -> RegistrationManager {
        return RegistrationManager()
    }
}
