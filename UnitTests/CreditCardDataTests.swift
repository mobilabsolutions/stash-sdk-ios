//
//  CreditCardDataTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class CreditCardDataTests: XCTestCase {
    let validExampleNumbers: [(String, CreditCardData.CreditCardType)] = [
        ("4111 1111 1111 1111", .visa), ("30569309025904", .diners),
        ("5500 0000 0000 0004", .mastercard), ("6011111111111117", .discover),
        ("378282246310005", .americanExpress), ("371449635398431", .americanExpress),
        ("378734493671000", .americanExpress), ("4222222222222", .visa),
        ("5105105105105100", .mastercard), ("5555555555554444", .mastercard),
        ("6011000990139424", .discover), ("38520000023237", .diners),
        ("3530111333300000", .jcb), ("3566002020360505", .jcb),
        ("6011 0000 0000 0004", .discover), ("3000 0000 0000 04", .diners),
        ("6011539588605619", .discover), ("6011382557750862", .discover),
        ("340168114776366", .americanExpress), ("379357047249690", .americanExpress),
        ("5101745120583627", .mastercard), ("6759649826438453", .maestroInternational),
        ("3530 1113 3330 0000", .jcb), ("6221 2345 6789 0123 450", .chinaUnionPay),
    ]

    let invalidExampleNumbers: [(String, CreditCardData.CreditCardType)] = [
        ("not-a-number", .unknown), ("123456789101112", .unknown),
    ]

    func testCorrectlyParsesCardMask() {
        guard let first = CreditCardData(cardNumber: "4111 1111 1111 1111", cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData()),
            let second = CreditCardData(cardNumber: "5500 0000 0000 0004", cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
        else { XCTFail("Credit Card data should be valid"); return }

        XCTAssertEqual(first.cardMask, 1111, "Card mask should equal last four digits of card number")
        XCTAssertEqual(second.cardMask, 4, "Card mask should equal last four digits of card number")
    }

    func testCorrectlyParsesCardType() {
        for (number, type) in self.validExampleNumbers + self.invalidExampleNumbers {
            let cleanedNumber = CreditCardUtils.cleanedNumber(number: number)
            let creditCardUtilsDeterminedType = CreditCardUtils.cardTypeFromNumber(cleanedNumber: cleanedNumber)
            XCTAssertEqual(creditCardUtilsDeterminedType, type, "Card \(number) should have type \(type) but has type \(creditCardUtilsDeterminedType)")

            guard let card = CreditCardData(cardNumber: number, cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
            else { continue }
            XCTAssertEqual(card.cardType, creditCardUtilsDeterminedType)
        }
    }

    func testCorrectlyLuhnValidatesNumbers() {
        for (valid, _) in self.validExampleNumbers {
            let cleanedNumber = CreditCardUtils.cleanedNumber(number: valid)
            XCTAssertTrue(CreditCardUtils.isLuhnValid(cleanedNumber: cleanedNumber), "\(valid) should be Luhn valid")
        }

        for (invalid, _) in self.invalidExampleNumbers {
            let cleanedNumber = CreditCardUtils.cleanedNumber(number: invalid)
            XCTAssertFalse(CreditCardUtils.isLuhnValid(cleanedNumber: cleanedNumber), "\(invalid) should be Luhn invalid")
        }
    }

    func testCorrectlyCleansNumbers() {
        let cleanNumbers = ["378282246310005", "5555555555554444", "379357047249690", "4111111111111111"]
        let uncleanNumbers = ["3782-8224-6310-005", "5555 5555-5555 4444", "37 93 57 04 72 49 69 0", "4111 1111 1111 1111"]

        for (cleanNumber, uncleanNumber) in zip(cleanNumbers, uncleanNumbers) {
            XCTAssertEqual(cleanNumber, CreditCardUtils.cleanedNumber(number: uncleanNumber))
            XCTAssertEqual(cleanNumber, CreditCardUtils.cleanedNumber(number: cleanNumber))
        }
    }
}
