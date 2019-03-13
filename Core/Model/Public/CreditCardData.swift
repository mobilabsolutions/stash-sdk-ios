//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public struct CreditCardData: RegistrationData {
    public let cardNumber: String
    public let cvv: String
    public let expiryMonth: Int
    public let expiryYear: Int
    public let billingData: BillingData
    public let holderName: String?
    public let cardType: CreditCardType

    public var cardMask: Int? {
        return Int(self.cardNumber[cardNumber.index(cardNumber.endIndex, offsetBy: -4) ..< cardNumber.endIndex])
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

    public init?(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String? = nil, billingData: BillingData) {
        let cleanedNumber = CreditCardUtils.cleanedNumber(number: cardNumber)
        guard CreditCardUtils.isLuhnValid(cleanedNumber: cleanedNumber)
        else { return nil }

        self.holderName = holderName
        self.cardNumber = cleanedNumber
        self.cvv = cvv
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.billingData = billingData
        self.cardType = CreditCardUtils.cardTypeFromNumber(cleanedNumber: cleanedNumber)
    }
}
