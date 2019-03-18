//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public typealias RegistrationResult = NetworkClientResult<String, MLError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

public class MobilabPaymentSDK {
    /// Configure the SDK
    ///
    /// - Parameter configuration: The configuration to use for subsequent operations
    public static func configure(configuration: MobilabPaymentConfiguration) {
        InternalPaymentSDK.sharedInstance.configure(configuration: configuration)
    }

    /// Add the payment service provider module to use for subsequent registrations
    ///
    /// - Parameter provider: The payment service provider module to add
    public static func addProvider(provider: PaymentServiceProvider) {
        InternalPaymentSDK.sharedInstance.addProvider(provider: provider)
    }

    /// Create a registration manager to use for registering payment methods
    ///
    /// - Returns: The registration manager
    public static func getRegisterManager() -> RegistrationManager {
        return RegistrationManager()
    }
}
