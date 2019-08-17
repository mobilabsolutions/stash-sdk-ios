//
//  Extensions.swift
//  Demo
//
//  Created by Rupali Ghate on 20.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

/// convert decimalNumber into currency for device Locale
extension NSDecimalNumber {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        return formatter.string(for: self) ?? ""
    }
}

extension UICollectionView {
    func reloadAsync() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { _ in
                completion?()

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

/// Constructs a string using payment method extra details.
/// - Returns:
//      - For credit card: "CC-mask • mm/yy"
///     - For SEPA: maksed IBAN string
///     - For PayPal: email address string
extension PaymentMethodAlias.ExtraAliasInfo {
    func formatToReadableDetails() -> String {
        let readableDetails: String

        switch self {
        case let .creditCard(details):
            readableDetails = self.formatCardDetails(extra: details)
        case let .sepa(details):
            readableDetails = details.maskedIban
        case let .payPal(details):
            readableDetails = details.email ?? ""
        }
        return readableDetails
    }

    private func formatCardDetails(extra: PaymentMethodAlias.CreditCardExtraInfo) -> String {
        return extra.creditCardMask + " • \(extra.expiryMonth)/\(extra.expiryYear)"
    }
}

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

extension PaymentMethodAlias.CreditCardExtraInfo: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CreditCardExtraInfoKeys.self)
        try container.encode(self.creditCardMask, forKey: .creditCardMask)
        try container.encode(self.creditCardType, forKey: .creditCardType)
        try container.encode(self.expiryMonth, forKey: .expiryMonth)
        try container.encode(self.expiryYear, forKey: .expiryYear)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CreditCardExtraInfoKeys.self)
        let creditCardMask = try container.decode(String.self, forKey: .creditCardMask)
        let creditCardType = try container.decode(CreditCardType.self, forKey: .creditCardType)
        let expiryYear = try container.decode(Int.self, forKey: .expiryYear)
        let expiryMonth = try container.decode(Int.self, forKey: .expiryMonth)

        self.init(creditCardMask: creditCardMask, expiryMonth: expiryMonth, expiryYear: expiryYear, creditCardType: creditCardType)
    }
}

extension PaymentMethodAlias.SEPAExtraInfo: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SEPAExtraInfoKeys.self)
        let maskedIban = try container.decode(String.self, forKey: .maskedIban)
        self.init(maskedIban: maskedIban)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SEPAExtraInfoKeys.self)
        try container.encode(self.maskedIban, forKey: .maskedIban)
    }
}

extension PaymentMethodAlias.PayPalExtraInfo: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PayPalExtraInfoKeys.self)
        try container.encode(self.email, forKey: .email)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PayPalExtraInfoKeys.self)
        let email = try container.decode(String?.self, forKey: .email)
        self.init(email: email)
    }
}

private enum ExtraAliasInfoKeys: CodingKey {
    case identifier
    case details
}

private enum CreditCardExtraInfoKeys: CodingKey {
    case creditCardMask
    case creditCardType
    case expiryMonth
    case expiryYear
}

private enum SEPAExtraInfoKeys: CodingKey {
    case maskedIban
}

private enum PayPalExtraInfoKeys: CodingKey {
    case email
}
