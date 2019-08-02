//
//  MobilabPaymentSDKBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// A bridge that allows usage of the payment SDK from Objective-C
@objc(MLMobilabPaymentSDK) public class MobilabPaymentSDKBridge: NSObject {
    /// Initialize the payment SDK using a given configuration. Can only be called once.
    ///
    /// - Parameter configuration: The configuration with which to initialize
    @objc public static func initialize(configuration: MobilabPaymentConfiguration) {
        MobilabPaymentSDK.initialize(configuration: configuration)
    }

    /// Configure the presented module UI
    ///
    /// - Parameter configuration: The UI configuration to use for future presentations
    @objc public static func configureUI(configuration: PaymentMethodUIConfigurationBridge) {
        MobilabPaymentSDK.configureUI(configuration: configuration.configuration)
    }

    /// Retrieve an instance of a registration manager with which to register payment methods with the SDK
    ///
    /// - Returns: The retrieved registration manager
    @objc public static func getRegistrationManager() -> RegistrationManagerBridge {
        return RegistrationManagerBridge(manager: MobilabPaymentSDK.getRegistrationManager())
    }
}
