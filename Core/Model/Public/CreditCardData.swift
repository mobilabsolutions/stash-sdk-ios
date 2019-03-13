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

    public enum CreditCardType: String {
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

    public init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String? = nil, billingData: BillingData) {
        self.holderName = holderName
        let cleanedNumber = CreditCardData.cleanedNumber(number: cardNumber)
        self.cardNumber = cleanedNumber
        self.cvv = cvv
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.billingData = billingData
        self.cardType = CreditCardData.cardTypeFromNumber(number: cleanedNumber)
    }
}

extension CreditCardData.CreditCardType {
    var iinRangePatterns: [String] {
        switch self {
        case .visa:
            return ["4[0-9]+"]
        case .mastercard:
            return ["5[1-5][0-9]+", "2(22[1-9]|[3-6][0-9][0-9]|7[0-9][0-9]|720)[0-9]+"]
        case .americanExpress:
            return ["(34|37)[0-9]+"]
        case .diners:
            return ["(36|38|39)[0-9]+", "30([0-5]|95)[0-9]+"]
        case .discover:
            return ["((6011|64|65)[0-9]+|62(2(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9(1[0-9]|2[0-5]))|[4-6][0-9]{3}|8[2-8][0-9]{2}))"]
        case .jcb:
            return ["35(28|29|[3-8][0-9])[0-9]+"]
        case .maestroInternational:
            #warning("Figure out how one differentialtes between maestro and china union pay")
            return ["(5(0|6-9)[0-9]+|6[0-9]+)"]
        case .carteBleue:
            #warning("Figure out which IIN range carte bleue has / how we can find out whether a card is carte bleue or not")
            return []
        case .chinaUnionPay:
            return ["62[0-9]+"]
        case .unknown:
            return []
        }
    }
}

extension CreditCardData.CreditCardType: CaseIterable {}

extension CreditCardData {
    static func cardTypeFromNumber(number: String) -> CreditCardType {
        // Get card type from number using IIN ranges as documented here:
        // https://en.wikipedia.org/wiki/Payment_card_number#Major_Industry_Identifier_.28MII.29
        let iin = String(number[number.startIndex ..< number.index(number.startIndex, offsetBy: 6)])

        return CreditCardType.allCases.first {
            $0.iinRangePatterns.contains {
                guard let range = iin.range(of: $0, options: .regularExpression)
                else { return false }
                return iin[range].count == iin.count
            }
        } ?? .unknown
    }

    static func cleanedNumber(number: String) -> String {
        return number.replacingOccurrences(of: "(\\s|\\-)", with: "", options: .regularExpression, range: nil)
    }
}
