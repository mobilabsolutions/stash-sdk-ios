//
//  SDKConfigurationError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public enum SDKConfigurationError: CustomStringConvertible, TitleProviding {
    /// SDK configuration is missing
    case configurationMissing
    /// SDK configuration is missing
    case clientMissing
    /// The SDK's public key is not set
    case publicKeyNotSet
    /// The SDK's endpoint is not set
    case endpointNotSet
    /// The provided SDK endpoint is not a valid URL
    case endpointNotValid
    /// There is no PSP set for payment method
    case paymentMethodIsMissingProvider(String)
    /// PSP does not support provided payment method/s
    case providerNotSupportingPaymentMethod(provider: String, paymentMethod: String)
    /// The used PSP was not configured correctly
    case pspInvalidConfiguration
    /// The return URL that is set for a given PSP is invalid
    case invalidReturnURL
    /// The backend is configured incorrectly for the performed action
    case invalidBackendConfiguration(description: String, code: String)

    public var description: String {
        switch self {
        case .configurationMissing:
            return "SDK configuration is missing"
        case .clientMissing:
            return "SDK network client is missing"
        case .publicKeyNotSet:
            return "SDK Public key is not set!"
        case .endpointNotSet:
            return "SDK Endpoint is not set"
        case .endpointNotValid:
            return "SDK Endpoint is not valid"
        case let .paymentMethodIsMissingProvider(paymentMethod):
            return "Payment service provider missing for \(paymentMethod)"
        case let .providerNotSupportingPaymentMethod(provider, paymentMethod):
            return "Payment service provider \(provider) missing for \(paymentMethod)"
        case .pspInvalidConfiguration:
            return "The payment service provider module was not correctly set up"
        case .invalidReturnURL:
            return "The return URL provided for the given PSP is invalid"
        case let .invalidBackendConfiguration(description, code):
            return "Invalid backend configuration: \(description) (\(code))"
        }
    }

    public var title: String {
        return "SDK configuration error"
    }
}

extension SDKConfigurationError: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SDKConfigurationErrorKey.self)

        switch self {
        case .clientMissing:
            try container.encode("CLIENT_MISSING", forKey: .type)
        case .configurationMissing:
            try container.encode("CONFIGURATION_MISSING", forKey: .type)
        case .endpointNotSet:
            try container.encode("ENDPOINT_NOT_SET", forKey: .type)
        case .endpointNotValid:
            try container.encode("ENDPOINT_NOT_VALID", forKey: .type)
        case .publicKeyNotSet:
            try container.encode("PUBLIC_KEY_NOT_SET", forKey: .type)
        case let .paymentMethodIsMissingProvider(provider):
            try container.encode("PAYMENT_METHOD_IS_MISSING_PROVIDER", forKey: .type)
            try container.encode(provider, forKey: .details)
        case let .providerNotSupportingPaymentMethod(provider, paymentMethod):
            try container.encode("PROVIDER_NOT_SUPPORTING_PAYMENT_METHOD", forKey: .type)
            try container.encode(CodableTwoTuple(first: provider, second: paymentMethod), forKey: .details)
        case .pspInvalidConfiguration:
            try container.encode("PSP_INVALID_CONFIGURATION", forKey: .type)
        case .invalidReturnURL:
            try container.encode("INVALID_RETURN_URL", forKey: .type)
        case let .invalidBackendConfiguration(description, code):
            try container.encode("INVALID_BACKEND_CONFIGURATION", forKey: .type)
            try container.encode(CodableTwoTuple(first: description, second: code), forKey: .details)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SDKConfigurationErrorKey.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "CLIENT_MISSING":
            self = .clientMissing
        case "CONFIGURATION_MISSING":
            self = .configurationMissing
        case "ENDPOINT_NOT_SET":
            self = .endpointNotSet
        case "ENDPOINT_NOT_VALID":
            self = .endpointNotValid
        case "PUBLIC_KEY_NOT_SET":
            self = .publicKeyNotSet
        case "PAYMENT_METHOD_IS_MISSING_PROVIDER":
            let provider = try container.decode(String.self, forKey: .details)
            self = .paymentMethodIsMissingProvider(provider)
        case "PROVIDER_NOT_SUPPORTING_PAYMENT_METHOD":
            let details = try container.decode(CodableTwoTuple<String, String>.self, forKey: .details)
            self = .providerNotSupportingPaymentMethod(provider: details.first, paymentMethod: details.second)
        case "PSP_INVALID_CONFIGURATION":
            self = .pspInvalidConfiguration
        case "INVALID_RETURN_URL":
            self = .invalidReturnURL
        case "INVALID_BACKEND_CONFIGURATION":
            let details = try container.decode(CodableTwoTuple<String, String>.self, forKey: .details)
            self = .invalidBackendConfiguration(description: details.first, code: details.second)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "The type \(type) does not exist for decoding SDKConfigurationError")
        }
    }
}

private enum SDKConfigurationErrorKey: CodingKey {
    case type
    case details
}
