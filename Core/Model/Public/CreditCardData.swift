//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

protocol CreditCardDataInitializible {
    init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String?, billingData: BillingData) throws
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
    /// The billing data to use when registering the credit card with the PSP
    public let billingData: BillingData
    /// The name of the credit card holder. Not required by every PSP
    public let holderName: String?
    /// The type of credit card (e.g. visa or mastercard) the number is associated with. This is determined on card initialization
    public let cardType: CreditCardType

    /// The number of digits that should be used to create the card mask
    private let numberOfDigitsForCardMask = 4

    /// The card mask (i.e. last 4 digits) of the card number
    public var cardMask: Int? {
        return Int(self.cardNumber[cardNumber.index(cardNumber.endIndex, offsetBy: -numberOfDigitsForCardMask)..<cardNumber.endIndex])
    }

    /// A human readable identifier for this credit card. Derived from the card number in the form XXXXXXXXXXXX 4111.
    public var humanReadableId: String? {
        let maskStartIndex = cardNumber.index(cardNumber.endIndex, offsetBy: -numberOfDigitsForCardMask)
        let maskString = self.cardNumber[maskStartIndex..<cardNumber.endIndex]
        let other = self.cardNumber[cardNumber.startIndex..<maskStartIndex].replacingOccurrences(of: "[0-9]", with: "X", options: .regularExpression, range: nil)
        return other + " " + maskString
    }

    public enum CreditCardType: String, CaseIterable {
        case visa = "VISA"
        case mastercard = "MASTERCARD"
        case americanExpress = "AMEX"
        case diners = "DINERS"
        case discover = "DISCOVER"
        case jcb = "JCB"
        case maestroInternational = "MAESTROINT"
        case carteBleue = "CARTEBLEUE"
        case chinaUnionPay = "CHINAUNION"
        case unknown = "UNKNOWN"
    }

    /// Initialize a new credit card. Validates credit card using Luhn's algorithm - if the validation fails, a MobilabPaymentError is thrown
    ///
    /// - Parameters:
    ///   - cardNumber: The credit card number. Spaces and dashes are allowed and will be filtered out.
    ///   - cvv: The CVV (three or four digit integer)
    ///   - expiryMonth: The month in which the credit card expires: 1 (January) - 12 (December)
    ///   - expiryYear: The year in which the credit card expires: 0-99
    ///   - holderName: The name of the credit card holder. Not required by every PSP
    ///   - billingData: The billing data to use when registering with the PSP
    /// - Throws: An MobilabPaymentError if validation is not successful
    public init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String? = nil, billingData: BillingData) throws {
        let cleanedNumber = CreditCardUtils.cleanedNumber(number: cardNumber)

        guard cleanedNumber.count > numberOfDigitsForCardMask
        else { throw MobilabPaymentError.validation(.invalidCreditCardNumber) }

        try CreditCardUtils.validateCVV(cvv: cvv)

        guard CreditCardUtils.isLuhnValid(cleanedNumber: cleanedNumber)
        else { throw MobilabPaymentError.validation(.invalidCreditCardNumber) }

        self.holderName = holderName
        self.cardNumber = cleanedNumber
        self.cvv = cvv
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.billingData = billingData
        self.cardType = CreditCardUtils.cardTypeFromNumber(cleanedNumber: cleanedNumber)
    }

    public func toCreditCardExtra() -> CreditCardExtra? {
        guard let cardMask = self.cardMask
        else { return nil }

        return CreditCardExtra(ccExpiry: "\(String(format: "%02d", self.expiryMonth))/\(String(format: "%02d", self.expiryYear))",
                               ccMask: cardMask,
                               ccType: self.cardType.rawValue)
    }
}
