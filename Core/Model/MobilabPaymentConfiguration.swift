//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// The SDK configuration
@objc(MLMobilabPaymentConfiguration) public class MobilabPaymentConfiguration: NSObject {
    /// Whether or not the SDK should write log messages to the console detailing the steps it takes
    @objc public var loggingEnabled = false

    /// Whether or not the SDK should instruct the Mobilab backend to run in test mode
    @objc public var useTestMode = false

    let publicKey: String
    let endpoint: String
    let uiConfiguration: PaymentMethodUIConfiguration?

    /// Initialize the SDK configuration
    ///
    /// - Parameters:
    ///   - publicKey: The SDK's public key for the Mobilab payment backend
    ///   - endpoint: The endpoint at which a Mobilab payment backend is deployed
    ///   - uiConfiguration: The UI configuration that should be used for SDK-generated UI
    public init(publicKey: String, endpoint: String, uiConfiguration: PaymentMethodUIConfiguration? = nil) {
        self.publicKey = publicKey
        self.endpoint = endpoint
        self.uiConfiguration = uiConfiguration
    }

    /// Initialize the SDK configuration (should only be used from Objective-C, use other initializer from Swift instead)
    ///
    /// - Parameters:
    ///   - publicKey: The SDK's public key for the Mobilab payment backend
    ///   - endpoint: The endpoint at which a Mobilab payment backend is deployed
    ///   - uiConfiguration: The UI configuration that should be used for SDK-generated UI
    @objc public init(publicKey: String, endpoint: String, uiConfiguration: MobilabPaymentSDKBridge.MLPaymentMethodUIConfiguration?) {
        self.publicKey = publicKey
        self.endpoint = endpoint
        self.uiConfiguration = uiConfiguration?.configuration
    }

    /// Validate and return the configuration URL
    ///
    /// - Returns: The endpoint URL
    /// - Throws: A `ConfigurationError` if the configuration is not set up correctly
    func endpointUrl() throws -> URL {
        guard !self.publicKey.isEmpty else {
            throw MobilabPaymentError.configuration(.publicKeyNotSet)
        }

        guard !self.endpoint.isEmpty else {
            throw MobilabPaymentError.configuration(.endpointNotSet)
        }

        guard let url = URL(string: self.endpoint) else {
            throw MobilabPaymentError.configuration(.endpointNotValid)
        }

        return url
    }
}
