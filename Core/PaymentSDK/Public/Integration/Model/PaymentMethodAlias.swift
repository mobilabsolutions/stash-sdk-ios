//
//  RegistrationResult.swift
//  StashCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public typealias RegistrationResult = Result<PaymentMethodAlias, StashError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

/// A successful payment method registration
public struct PaymentMethodAlias {
    /// The alias with which to access the payment method in the future
    public let alias: String?
    /// The type of payment method that was registered
    public let paymentMethodType: PaymentMethodType
    /// More information about the created alias and associated payment method
    public let extraAliasInfo: ExtraAliasInfo

    /// Information regarding a created alias and associated payment method
    public enum ExtraAliasInfo {
        /// The associated payment method was a credit card
        case creditCard(CreditCardExtraInfo)
        /// The associated payment method was a SEPA method
        case sepa(SEPAExtraInfo)
        /// The associated payment method was a PayPal method
        case payPal(PayPalExtraInfo)
    }

    /// More information about a registered credit card alias
    public struct CreditCardExtraInfo {
        /// The mask of the credit card number (last four digits)
        public let creditCardMask: String
        /// The expiry month (1-12) of the credit card
        public let expiryMonth: Int
        /// The expiry year of the credit card (0-99)
        public let expiryYear: Int
        /// The type of credit card that was registered
        public let creditCardType: CreditCardType

        public init(creditCardMask: String, expiryMonth: Int, expiryYear: Int, creditCardType: CreditCardType) {
            self.creditCardMask = creditCardMask
            self.creditCardType = creditCardType
            self.expiryYear = expiryYear
            self.expiryMonth = expiryMonth
        }
    }

    /// More information about a registered SEPA alias
    public struct SEPAExtraInfo {
        /// The masked registered IBAN (e.g. "DEXX XXXX XXXX XXXX XX6789")
        public let maskedIban: String

        public init(maskedIban: String) {
            self.maskedIban = maskedIban
        }
    }

    /// More information about a registered PayPal alias
    public struct PayPalExtraInfo {
        /// The user's payment email address (if provided)
        public let email: String?

        public init(email: String?) {
            self.email = email
        }
    }
}
