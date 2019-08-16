//
//  StashConfiguration.swift
//  StashCore
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// The SDK configuration
@objc(MLStashConfiguration) public class StashConfiguration: NSObject {
    /// Whether or not the SDK should write log messages to the console detailing the steps it takes
    @objc public var loggingEnabled = false

    /// Whether or not the SDK should instruct the Stash backend to run in test mode
    @objc public var useTestMode = false

    let publishableKey: String
    let endpoint: String
    let uiConfiguration: PaymentMethodUIConfiguration?
    let integrations: [PaymentProviderIntegration]

    /// Initialize the SDK configuration
    ///
    /// - Parameters:
    ///   - publishableKey: The SDK's publishable key for the Stash payment backend
    ///   - endpoint: The endpoint at which a Stash payment backend is deployed
    ///   - integrations: The payment service provider integrations that should be registered
    ///   - uiConfiguration: The UI configuration that should be used for SDK-generated UI
    public init(publishableKey: String, endpoint: String, integrations: [PaymentProviderIntegration], uiConfiguration: PaymentMethodUIConfiguration? = nil) {
        self.publishableKey = publishableKey
        self.endpoint = endpoint
        self.uiConfiguration = uiConfiguration
        self.integrations = integrations
    }

    /// Initialize the SDK configuration (should only be used from Objective-C, use the other initializer from Swift instead)
    ///
    /// - Parameters:
    ///   - publishableKey: The SDK's publishableKey for the Stash payment backend
    ///   - endpoint: The endpoint at which a Stash payment backend is deployed
    ///   - integrations: The payment service provider integrations that should be registered
    ///   - uiConfiguration: The UI configuration that should be used for SDK-generated UI
    @objc public init(publishableKey: String,
                      endpoint: String,
                      integrations: [PaymentProviderIntegrationBridge],
                      uiConfiguration: PaymentMethodUIConfigurationBridge?) {
        self.publishableKey = publishableKey
        self.endpoint = endpoint
        self.uiConfiguration = uiConfiguration?.configuration
        self.integrations = integrations.map { $0.integration }
    }

    /// Validate and return the configuration URL
    ///
    /// - Returns: The endpoint URL
    /// - Throws: A `ConfigurationError` if the configuration is not set up correctly
    func endpointUrl() throws -> URL {
        guard !self.publishableKey.isEmpty else {
            throw StashError.configuration(.publishableKeyNotSet)
        }

        guard !self.endpoint.isEmpty else {
            throw StashError.configuration(.endpointNotSet)
        }

        guard let url = URL(string: self.endpoint) else {
            throw StashError.configuration(.endpointNotValid)
        }

        return url
    }
}
