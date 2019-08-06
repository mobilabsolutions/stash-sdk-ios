//
//  PaymentMethodAliasBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge that allows accessing created payment method aliases from Objective-C.
@objc(MLPaymentMethodAlias) public class PaymentMethodAliasBridge: NSObject {
    /// The created alias
    @objc public let alias: String?
    /// The type of payment method that was created (e.g. `sepa`, `payPal` or `creditCard`)
    @objc public let paymentMethodType: String
    /// More information about the registered alias.
    @objc public let extraAliasInfo: ExtraAliasInfoBridge

    /// A bridge that allows accessing extra alias info from Objective-C
    @objc(MLExtraAliasInfo) public class ExtraAliasInfoBridge: NSObject {
        /// More information about the registered credit card (if the operation did indeed register one, else `nil`)
        @objc public let creditCardExtraInfo: CreditCardExtraInfoBridge?
        /// More information about the registered SEPA method (if the operation did indeed register one, else `nil`)
        @objc public let sepaExtraInfo: SEPAExtraInfoBridge?
        /// More information about the registered PayPal method (if the operation did indeed register one, else `nil`)
        @objc public let payPalExtraInfo: PayPalExtraInfoBridge?

        init(creditCardExtraInfo: CreditCardExtraInfoBridge?, sepaExtraInfo: SEPAExtraInfoBridge?, payPalExtraInfo: PayPalExtraInfoBridge?) {
            self.creditCardExtraInfo = creditCardExtraInfo
            self.sepaExtraInfo = sepaExtraInfo
            self.payPalExtraInfo = payPalExtraInfo
        }

        /// A bridge that allows accessing credit card extra alias info from Objective-C
        @objc(MLCreditCardExtraInfo) public class CreditCardExtraInfoBridge: NSObject {
            /// The credit card mask (last four digits of the card number)
            @objc public let creditCardMask: String
            /// The credit card expiry month (1-12)
            @objc public let expiryMonth: Int
            /// The credit card expiry year (0-99)
            @objc public let expiryYear: Int
            /// The credit card type (e.g. `visa`)
            @objc public let creditCardType: String

            init(creditCardMask: String, expiryMonth: Int, expiryYear: Int, creditCardType: String) {
                self.creditCardMask = creditCardMask
                self.expiryMonth = expiryMonth
                self.expiryYear = expiryYear
                self.creditCardType = creditCardType
            }
        }

        /// A bridge that allows accessing SEPA extra alias info from Objective-C
        @objc(MLSEPAExtraInfo) public class SEPAExtraInfoBridge: NSObject {
            /// The registered IBAN (masked, e.g. "DEXX XXXX XXXX XXXX XX6789")
            @objc public let maskedIban: String

            init(maskedIban: String) {
                self.maskedIban = maskedIban
            }
        }

        /// A bridge that allows accessing PayPal extra alias info from Objective-C
        @objc(MLPayPalExtraInfo) public class PayPalExtraInfoBridge: NSObject {
            /// The user's email address if it could be retrieved
            @objc public let email: String?

            init(email: String?) {
                self.email = email
            }
        }
    }

    init(alias: String?, paymentMethodType: PaymentMethodType, extraAliasInfo: ExtraAliasInfoBridge) {
        self.alias = alias
        self.paymentMethodType = paymentMethodType.rawValue
        self.extraAliasInfo = extraAliasInfo
    }
}

internal extension PaymentMethodAlias.ExtraAliasInfo {
    var bridgedAliasInfo: PaymentMethodAliasBridge.ExtraAliasInfoBridge {
        switch self {
        case let .creditCard(details):
            return PaymentMethodAliasBridge.ExtraAliasInfoBridge(creditCardExtraInfo: details.bridgedExtraInfo,
                                                                 sepaExtraInfo: nil,
                                                                 payPalExtraInfo: nil)
        case let .sepa(details):
            return PaymentMethodAliasBridge.ExtraAliasInfoBridge(creditCardExtraInfo: nil,
                                                                 sepaExtraInfo: details.bridgedExtraInfo,
                                                                 payPalExtraInfo: nil)
        case let .payPal(details):
            return PaymentMethodAliasBridge.ExtraAliasInfoBridge(creditCardExtraInfo: nil,
                                                                 sepaExtraInfo: nil,
                                                                 payPalExtraInfo: details.bridgedExtraInfo)
        }
    }
}

internal extension PaymentMethodAlias.CreditCardExtraInfo {
    typealias Bridge = PaymentMethodAliasBridge.ExtraAliasInfoBridge.CreditCardExtraInfoBridge

    var bridgedExtraInfo: Bridge {
        return Bridge(creditCardMask: self.creditCardMask,
                      expiryMonth: self.expiryMonth,
                      expiryYear: self.expiryYear,
                      creditCardType: self.creditCardType.rawValue)
    }
}

internal extension PaymentMethodAlias.SEPAExtraInfo {
    typealias Bridge = PaymentMethodAliasBridge.ExtraAliasInfoBridge.SEPAExtraInfoBridge

    var bridgedExtraInfo: Bridge {
        return Bridge(maskedIban: self.maskedIban)
    }
}

internal extension PaymentMethodAlias.PayPalExtraInfo {
    typealias Bridge = PaymentMethodAliasBridge.ExtraAliasInfoBridge.PayPalExtraInfoBridge

    var bridgedExtraInfo: Bridge {
        return Bridge(email: self.email)
    }
}
