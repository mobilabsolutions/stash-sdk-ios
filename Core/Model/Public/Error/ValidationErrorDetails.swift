//
//  ValidationErrorDetails.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
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
    /// The expiration year is invalid
    case invalidExpirationDate
    /// Other PSP-specific validation failed
    case other(description: String, thirdPartyErrorDetails: String?)

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
        case .invalidExpirationDate:
            return "The expiration date is invalid"
        case .other(let description, _):
            return description
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
        case .invalidExpirationDate:
            return "Credit card validation error"
        case .other:
            return "Validation error"
        }
    }

    private var identifier: String {
        switch self {
        case .invalidIBAN:
            return "invalidIBAN"
        case .invalidCreditCardNumber:
            return "invalidCreditCardNumber"
        case .invalidCVV:
            return "invalidCVV"
        case .creditCardMissingHolderName:
            return "creditCardMissingHolderName"
        case .billingMissingName:
            return "billingMissingName"
        case .cardExtraNotExtractable:
            return "cardExtraNotExtractable"
        case .cardTypeNotSupported:
            return "cardTypeNotSupported"
        case .bicMissing:
            return "bicMissing"
        case .invalidExpirationDate:
            return "invalidExpirationDate"
        case .other:
            return "other"
        }
    }

    private var details: CodableTwoTuple<String, String?>? {
        switch self {
        case let .other(description, thirdPartyErrorDetails):
            return CodableTwoTuple(first: description, second: thirdPartyErrorDetails)
        default:
            return nil
        }
    }
}

extension ValidationErrorDetails: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ValidationErrorKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.details, forKey: .details)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ValidationErrorKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)

        switch identifier {
        case "invalidIBAN":
            self = .invalidIBAN
        case "invalidCreditCardNumber":
            self = .invalidCreditCardNumber
        case "invalidCVV":
            self = .invalidCVV
        case "creditCardMissingHolderName":
            self = .creditCardMissingHolderName
        case "billingMissingName":
            self = .billingMissingName
        case "cardExtraNotExtractable":
            self = .cardExtraNotExtractable
        case "cardTypeNotSupported":
            self = .cardTypeNotSupported
        case "bicMissing":
            self = .bicMissing
        case "invalidExpirationDate":
            self = .invalidExpirationDate
        case "other":
            let details = try container.decode(CodableTwoTuple<String, String?>.self, forKey: .details)
            self = .other(description: details.first, thirdPartyErrorDetails: details.second)
        default:
            throw DecodingError.dataCorruptedError(forKey: .identifier, in: container, debugDescription: "The identifier could not be decoded for type ValidationErrorDetails")
        }
    }
}

private enum ValidationErrorKeys: CodingKey {
    case identifier
    case details
}
