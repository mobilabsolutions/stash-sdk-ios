//
//  CreditCardExtra.swift
//  StashCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A model that contains all extra information that should be
/// propagated to the payment SDK backend when registering a credit card.
/// This will and should not be used by clients directly but only by
/// the core SDK and modules.
public struct CreditCardExtra: Codable {
    /// The card expiry date in the form MM/YY
    public let ccExpiry: String
    /// The card mask: last four digits of the card number
    public let ccMask: String
    /// The type of credit card that is registered (e.g. VISA or MasterCard)
    public let ccType: String
    /// The name of the credit card holder.
    public let ccHolderName: String?
    /// Encrypted card number for Adyen
    public let encryptedCardNumber: String?
    /// Encrypted security code for Adyen
    public let encryptedSecurityCode: String?
    /// Encrypted expiry month for Adyen
    public let encryptedExpiryMonth: String?
    /// Encrypted expiry year for Adyen
    public let encryptedExpiryYear: String?
    /// The identifying data for the current device. Used for anti-fraud protection by Braintree
    public let deviceData: String?
    /// The Braintree nonce which addresses the payment method with Credit Card
    public let nonce: String?

    public init(ccExpiry: String, ccMask: String, ccType: String,
                ccHolderName: String?,
                encryptedCardNumber: String? = nil,
                encryptedSecurityCode: String? = nil,
                encryptedExpiryMonth: String? = nil,
                encryptedExpiryYear: String? = nil,
                nonce: String? = nil,
                deviceData: String? = nil) {
        self.ccExpiry = ccExpiry
        self.ccMask = ccMask
        self.ccType = ccType
        self.ccHolderName = ccHolderName

        self.encryptedCardNumber = encryptedCardNumber
        self.encryptedSecurityCode = encryptedSecurityCode
        self.encryptedExpiryMonth = encryptedExpiryMonth
        self.encryptedExpiryYear = encryptedExpiryYear

        self.nonce = nonce
        self.deviceData = deviceData
    }
}

/// A protocol used for preparing CreditCardExtra data
/// This will and should not be used by clients directly but only by
/// the core SDK and modules.
public protocol CreditCardExtraPreparatorProtocol {
    func prepare() throws -> CreditCardExtra
}
