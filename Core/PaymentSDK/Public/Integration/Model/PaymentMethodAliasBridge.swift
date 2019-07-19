//
//  PaymentMethodAliasBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLPaymentMethodAlias) public class PaymentMethodAliasBridge: NSObject {
    @objc public let alias: String?
    @objc public let paymentMethodType: String
    @objc public let extraAliasInfo: ExtraAliasInfoBridge
    
    @objc(MLExtraAliasInfo) public class ExtraAliasInfoBridge: NSObject {
        @objc public let creditCardExtraInfo: CreditCardExtraInfoBridge?
        @objc public let sepaExtraInfo: SEPAExtraInfoBridge?
        @objc public let payPalExtraInfo: PayPalExtraInfoBridge?
        
        init(creditCardExtraInfo: CreditCardExtraInfoBridge?, sepaExtraInfo: SEPAExtraInfoBridge?, payPalExtraInfo: PayPalExtraInfoBridge?) {
            self.creditCardExtraInfo = creditCardExtraInfo
            self.sepaExtraInfo = sepaExtraInfo
            self.payPalExtraInfo = payPalExtraInfo
        }
        
        @objc(MLCreditCardExtraInfo) public class CreditCardExtraInfoBridge: NSObject {
            @objc public let creditCardMask: String
            @objc public let expiryMonth: Int
            @objc public let expiryYear: Int
            @objc public let creditCardType: String
            
            init(creditCardMask: String, expiryMonth: Int, expiryYear: Int, creditCardType: String) {
                self.creditCardMask = creditCardMask
                self.expiryMonth = expiryMonth
                self.expiryYear = expiryYear
                self.creditCardType = creditCardType
            }
        }
        
        @objc(MLSEPAExtraInfo) public class SEPAExtraInfoBridge: NSObject {
            @objc public let maskedIban: String
            
            init(maskedIban: String) {
                self.maskedIban = maskedIban
            }
        }
        
        @objc(MLPayPalExtraInfo) public class PayPalExtraInfoBridge: NSObject {
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
