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
    /// The SDK's publishable key is not set
    case publishableKeyNotSet
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
        case .publishableKeyNotSet:
            return "SDK Publishable key is not set!"
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
