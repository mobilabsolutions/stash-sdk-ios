//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

protocol CreditCardDataInitializible {
    init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, country: String?, billingData: BillingData) throws
}

/// CreditCardData contains all data necessary for registering a credit card with a payment service provider
public struct CreditCardData: RegistrationData, CreditCardDataInitializible {
    /// The (cleaned) credit card number
    public let cardNumber: String
    /// The CVV associated with the credit card
    public let cvv: String
    /// The month in which the credit card expires: 1 (January) - 12 (December)
    public let expiryMonth: Int
    /// The year in which the credit card expires: 0-99
    public let expiryYear: Int
    /// The billing data to use when registering the credit card with the PSP.
    /// Some PSPs require the holder name to be specified here.
    public let billingData: BillingData
    /// The type of credit card (e.g. visa or mastercard) the number is associated with. This is determined on card initialization
    public let cardType: CreditCardType
    /// The country field takes an ISO country code. e.g. 'DE' for Germany and is mandatory for some PSPs (e.g. BSPayone)
    public let country: String?

    /// The number of digits that should be used to create the card mask
    static let numberOfDigitsForCardMask = 4

    /// The card mask (i.e. VISA-1111) of the card number
    public var cardMask: String {
        let lastDigits = String(self.cardNumber[cardNumber.index(cardNumber.endIndex, offsetBy: -CreditCardData.numberOfDigitsForCardMask)..<cardNumber.endIndex])
        return lastDigits
    }

    /// Extract all necessary extra alias info data from this payment method
    public var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo {
        let extra = PaymentMethodAlias.CreditCardExtraInfo(creditCardMask: self.cardMask,
                                                           expiryMonth: self.expiryMonth,
                                                           expiryYear: self.expiryYear,
                                                           creditCardType: self.cardType)
        return .creditCard(extra)
    }

    /// Initialize a new credit card. Validates credit card using Luhn's algorithm - if the validation fails, a StashError is thrown
    ///
    /// - Parameters:
    ///   - cardNumber: The credit card number. Spaces and dashes are allowed and will be filtered out.
    ///   - cvv: The CVV (three or four digit integer)
    ///   - expiryMonth: The month in which the credit card expires: 1 (January) - 12 (December)
    ///   - expiryYear: The year in which the credit card expires: 0-99
    ///   - country: ISO code of the country of the credit card holder. Not required by every PSP.
    ///   - billingData: The billing data to use when registering with the PSP
    /// - Throws: An StashError if validation is not successful
    public init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, country: String?, billingData: BillingData) throws {
        let cleanedNumber = CreditCardUtils.cleanedNumber(number: cardNumber)

        try CreditCardUtils.validateCVV(cvv: cvv)
        try CreditCardUtils.validateCreditCardNumber(cardNumber: cardNumber)

        self.cardNumber = cleanedNumber
        self.cvv = cvv
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.billingData = billingData
        self.cardType = CreditCardUtils.cardTypeFromNumber(cleanedNumber: cleanedNumber)
        self.country = country
    }

    /// Create a credit card extra from this payment method for use with the backend
    ///
    /// - Returns: The credit card extra instance
    public func toCreditCardExtra() -> CreditCardExtra? {
        return CreditCardExtra(ccExpiry: "\(String(format: "%02d", self.expiryMonth))/\(String(format: "%02d", self.expiryYear))",
                               ccMask: self.cardMask,
                               ccType: self.cardType.rawValue,
                               ccHolderName: self.billingData.name?.fullName)
    }
}
