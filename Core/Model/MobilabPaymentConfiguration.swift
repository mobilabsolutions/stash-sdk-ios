//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// An error rooting from configuration issues
public enum ConfigurationError: Error {
    /// The SDK's public key is not set
    case publicKeyNotSet
    /// The SDK's endpoint is not set
    case endpointNotSet
    /// The provided SDK endpoint is not a valid URL
    case endpointNotValid
    /// The SDK's payment provider was not set
    case providerNotSet

    func description() -> String {
        switch self {
        case .publicKeyNotSet:
            return "SDK Public key is not set!"
        case .endpointNotSet:
            return "SDK Endpoint is not set"
        case .endpointNotValid:
            return "SDK Endpoint is not valid"
        case .providerNotSet:
            return "No Provider found. Please add default provider"
        }
    }
}

/// The SDK configuration
@objc(MLMobilabPaymentConfiguration) public class MobilabPaymentConfiguration: NSObject {
    /// Whether or not the SDK should write log messages to the console detailing the steps it takes
    @objc public var loggingEnabled = false

    /// Whether or not the SDK should instruct the Mobilab backend to run in test mode
    @objc public var useTestMode = false

    let publicKey: String
    let endpoint: String

    /// Initialize the SDK configuration
    ///
    /// - Parameters:
    ///   - publicKey: The SDK's public key for the Mobilab payment backend
    ///   - endpoint: The endpoint at which a Mobilab payment backend is deployed
    @objc public init(publicKey: String, endpoint: String) {
        self.publicKey = publicKey
        self.endpoint = endpoint
    }

    /// Validate and return the configuration URL
    ///
    /// - Returns: The endpoint URL
    /// - Throws: A `ConfigurationError` if the configuration is not set up correctly
    @objc public func endpointUrl() throws -> URL {
        guard !self.publicKey.isEmpty else {
            throw ConfigurationError.publicKeyNotSet
        }

        guard !self.endpoint.isEmpty else {
            throw ConfigurationError.endpointNotSet
        }

        guard let url = URL(string: self.endpoint) else {
            throw ConfigurationError.endpointNotValid
        }

        return url
    }
}
