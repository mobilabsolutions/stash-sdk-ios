//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

enum APIEndpoints: String {
    case production = "https://p.mblb.net/api/v1"
    case test = "https://payment-dev.mblb.net/api/v1"
}

public enum ConfigurationError: Error {
    case publicKeyNotSet
    case endpointNotSet
    case endpointNotValid
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

@objc(MLMobilabPaymentConfiguration) public class MobilabPaymentConfiguration: NSObject {
    let publicKey: String
    let endpoint: String

    @objc public var loggingEnabled = false

    @objc public init(publicKey: String, endpoint: String) {
        self.publicKey = publicKey
        self.endpoint = endpoint
    }

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
