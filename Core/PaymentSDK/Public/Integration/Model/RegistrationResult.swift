//
//  RegistrationResult.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public typealias RegistrationResult = Result<PaymentMethodAlias, MobilabPaymentError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

/// A successful payment method registration
public struct PaymentMethodAlias {
    /// The alias with which to access the payment method in the future
    public let alias: String?
    /// The type of payment method that was registered
    public let paymentMethodType: PaymentMethodType
    /// A human readable identifier for the payment method (e.g. IBAN or masked credit card number)
    public let extraAliasInfo: ExtraAliasInfo

    public enum ExtraAliasInfo {
        case creditCard(CreditCardExtraInfo)
        case sepa(SEPAExtraInfo)
        case payPal(PayPalExtraInfo)
    }

    public struct CreditCardExtraInfo {
        public let creditCardMask: String
        public let expiryMonth: Int
        public let expiryYear: Int
        public let creditCardType: CreditCardType
    }

    public struct SEPAExtraInfo {
        public let maskedIban: String
    }

    public struct PayPalExtraInfo {
        public let email: String?
    }
}

extension PaymentMethodAlias: Codable {}

extension PaymentMethodAlias.ExtraAliasInfo: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ExtraAliasInfoKeys.self)
        switch try container.decode(String.self, forKey: .identifier) {
        case "creditCard":
            let details = try container.decode(PaymentMethodAlias.CreditCardExtraInfo.self, forKey: .details)
            self = .creditCard(details)
        case "sepa":
            let details = try container.decode(PaymentMethodAlias.SEPAExtraInfo.self, forKey: .details)
            self = .sepa(details)
        case "payPal":
            let details = try container.decode(PaymentMethodAlias.PayPalExtraInfo.self, forKey: .details)
            self = .payPal(details)
        default:
            throw DecodingError.dataCorruptedError(forKey: .identifier, in: container, debugDescription: "The identifier could not be decoded for ExtraAliasInfo")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ExtraAliasInfoKeys.self)
        switch self {
        case let .creditCard(details):
            try container.encode("creditCard", forKey: .identifier)
            try container.encode(details, forKey: .details)
        case let .sepa(details):
            try container.encode("sepa", forKey: .identifier)
            try container.encode(details, forKey: .details)
        case let .payPal(details):
            try container.encode("payPal", forKey: .identifier)
            try container.encode(details, forKey: .details)
        }
    }
}

extension PaymentMethodAlias.CreditCardExtraInfo: Codable {}

extension PaymentMethodAlias.SEPAExtraInfo: Codable {}

extension PaymentMethodAlias.PayPalExtraInfo: Codable {}

private enum ExtraAliasInfoKeys: CodingKey {
    case identifier
    case details
}
