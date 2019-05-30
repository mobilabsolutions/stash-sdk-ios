//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public class MobilabPaymentSDK {
    /// Configure the SDK
    ///
    /// - Parameter configuration: The configuration to use for subsequent operations
    public static func initialize(configuration: MobilabPaymentConfiguration) {
        InternalPaymentSDK.sharedInstance.initialize(configuration: configuration)
    }

    /// Configure the SDK's UI
    ///
    /// - Parameter configuration: The configuration to apply to the presented UI
    public static func configureUI(configuration: PaymentMethodUIConfiguration) {
        InternalPaymentSDK.sharedInstance.configureUI(configuration: configuration)
    }

    /// Create a registration manager to use for registering payment methods
    ///
    /// - Returns: The registration manager
    public static func getRegistrationManager() -> RegistrationManager {
        return RegistrationManager()
    }
}
