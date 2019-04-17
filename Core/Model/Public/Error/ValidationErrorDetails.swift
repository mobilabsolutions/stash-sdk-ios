//
//  ValidationErrorDetails.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public enum ValidationErrorDetails: CustomStringConvertible, TitleProviding {
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
    /// The given PSP does not support the cards of this type
    case cardTypeNotSupported
    /// The PSP requires the BIC to be present but it is missing
    case bicMissing

    public var description: String {
        switch self {
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
        case .cardTypeNotSupported:
            return "Card type not supported by PSP"
        case .bicMissing:
            return "The BIC is required but missing"
        }
    }

    public var title: String {
        switch self {
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
        case .cardTypeNotSupported:
            return "Card type not supported"
        case .bicMissing:
            return "BIC required"
        }
    }
}