//
//  MobilabPaymentError.swift
//  MobilabPayment
//
//  Created by Borna Beakovic on 02/04/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public enum MobilabPaymentError: Error, Equatable {
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
    case providerNotSupportingPaymentMethod(String, String)

    /// SEPA IBAN is invalid
    case invalidIBAN
    /// Credit card number is invalid
    case invalidCreditCardNumber
    /// Credit card CVV is invalid
    case invalidCVV
    /// Credit card data is missing holder name
    case creditCardMissingHolderName
    /// Billing data is missing name
    case billingMissingName
    /// Card extra could not be extracted
    case cardExtraNotExtractable

    /// Backend error with a custome message
    case backendError(String)
    /// SDK UI error with a custom message
    case sdkUIError(String?)
    /// PSP related error with a custom message
    case pspError(String)
    /// Temporary PSP error with a custom message
    case pspTemporaryError(String)
    /// Unkown payment method data found in PSP module
    case pspUnknownPaymentMethodData
    /// Invalid configuration data in PSP module
    case pspInvalidConfigurationData
    /// Supplied credit card type is not supported in PSP
    case pspCreditCardTypeNotSupported
    /// PSP unknown error
    case pspUnknownError(MobilabPaymentProvider)
    /// API error with a custom message
    case apiError(String)
    /// API request failed
    case requestFailed(Int, String)
    /// API response is not valid
    case responseNotValid
    /// Unknown MobilabPayment error
    case unknown
}

public enum MobilabPaymentApiError<S: MobilabPaymentErrorConvertible>: Error, MobilabPaymentErrorConvertible {
    case apiError(S)

    public func toMobilabPaymentError() -> MobilabPaymentError {
        switch self {
        case let .apiError(error):
            return error.toMobilabPaymentError()
        }
    }
}

extension MobilabPaymentError {
    public var title: String {
        switch self {
        case .configurationMissing, .clientMissing, .publicKeyNotSet, .endpointNotSet, .endpointNotValid, .paymentMethodIsMissingProvider, .providerNotSupportingPaymentMethod:
            return "SDK configuration error"
        case .invalidIBAN:
            return "IBAN is not valid"
        case .invalidCreditCardNumber:
            return "Credit card validation error"
        case .invalidCVV:
            return "Credit card validation error"
        case .creditCardMissingHolderName:
            return "Credit card validation error"
        case .billingMissingName:
            return "Billing data validation error"
        case .cardExtraNotExtractable:
            return "Card extra not extractable"
        case .backendError:
            return "Backend error"
        case .sdkUIError:
            return "SDK UI error"
        case .pspError, .pspUnknownPaymentMethodData, .pspInvalidConfigurationData, .pspCreditCardTypeNotSupported,
             .pspUnknownError, .pspTemporaryError:
            return "PSP Error"
        case .apiError, .requestFailed, .responseNotValid, .unknown:
            return "Api error"
        }
    }
}

extension MobilabPaymentError: CustomStringConvertible {
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
        case .invalidIBAN:
            return "The provided IBAN is not valid"
        case .invalidCreditCardNumber:
            return "Credit card number is not valid"
        case .invalidCVV:
            return "CVV should be numeric"
        case .creditCardMissingHolderName:
            return "Credit card holder name is missing"
        case .billingMissingName:
            return "Billing data name is missing"
        case .cardExtraNotExtractable:
            return "Internal SDK error: Could not read alias extra from payment method"
        case let .backendError(message):
            return message
        case let .sdkUIError(message):
            return message ?? "An error occurred while the user was adding a payment method using the module UI"
        case let .pspError(message):
            return message
        case let .pspTemporaryError(message):
            return message
        case .pspUnknownPaymentMethodData:
            return "Unknown payment method data"
        case .pspInvalidConfigurationData:
            return "The provided configuration data is invalid"
        case .pspCreditCardTypeNotSupported:
            return "The provided credit card type is not supported"
        case let .pspUnknownError(provider):
            return "An unknown error occurred while handling payment method registration in \(provider) module"
        case let .apiError(error):
            return error
        case let .requestFailed(_, error):
            return error
        case .responseNotValid:
            return "Response not valid"
        case .unknown:
            return "Unknown error"
        }
    }
}
