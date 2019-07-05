//
//  CreditCardDataTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class CreditCardDataTests: XCTestCase {
    let validExampleNumbers: [(String, CreditCardType)] = [
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

    let invalidExampleNumbers: [(String, CreditCardType)] = [
        ("not-a-number", .unknown), ("123456789101112", .unknown),
    ]

    func testCorrectlyParsesCardMask() throws {
        let first = try CreditCardData(cardNumber: "4111 1111 1111 1111", cvv: "123", expiryMonth: 9, expiryYear: 21, country: "DE", billingData: BillingData())
        let second = try CreditCardData(cardNumber: "5500 0000 0000 0004", cvv: "123", expiryMonth: 9, expiryYear: 21, country: "DE", billingData: BillingData())

        XCTAssertEqual(first.cardMask, "1111", "Card mask should equal last four digits of card number")
        XCTAssertEqual(second.cardMask, "0004", "Card mask should equal last four digits of card number")
    }

    func testCorrectlyParsesCardType() throws {
        for (number, type) in self.validExampleNumbers + self.invalidExampleNumbers {
            let cleanedNumber = CreditCardUtils.cleanedNumber(number: number)
            let creditCardUtilsDeterminedType = CreditCardUtils.cardTypeFromNumber(cleanedNumber: cleanedNumber)
            XCTAssertEqual(creditCardUtilsDeterminedType, type,
                           "Card \(number) should have type \(type) but has type \(creditCardUtilsDeterminedType)")

            if let card = try? CreditCardData(cardNumber: number, cvv: "123", expiryMonth: 9, expiryYear: 21, country: "DE", billingData: BillingData()) {
                XCTAssertEqual(card.cardType, creditCardUtilsDeterminedType,
                               "Expected card type \(creditCardUtilsDeterminedType) for credit card data but got \(card.cardType)")
            }
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
            XCTAssertEqual(cleanNumber, CreditCardUtils.cleanedNumber(number: uncleanNumber),
                           "Cleaning \(uncleanNumber) did not result in \(cleanNumber)")
            XCTAssertEqual(cleanNumber, CreditCardUtils.cleanedNumber(number: cleanNumber), "Cleaning a clean number should not change the number")
        }
    }

    func testCorrectlyFormatsNumbers() {
        let formatted: [(String, CreditCardType)] = [
            ("4111 1111 1111 1111", .visa), ("3056 9309 0259 04", .diners),
            ("5500 0000 0000 0004", .mastercard), ("6011 1111 1111 1117", .discover),
            ("3782 822463 10005", .americanExpress), ("3714 496353 98431", .americanExpress),
            ("3787 344936 71000", .americanExpress), ("4222 2222 2222 2", .visa),
            ("5105 1051 0510 5100", .mastercard), ("5555 5555 5555 4444", .mastercard),
            ("6011 0009 9013 9424", .discover), ("3852 0000 0232 37", .diners),
        ]
        let unformatted = [
            "4111111111111111", "30-569309 0259-04", "5500000000000004", "6011111111111117", "378282246310005",
            "37-14 4-963-53-9-8431", "3 7 87 34 4 936 71 00 0", "4222222222222", "5105105105105100",
            "5555-55-555-5554444", "6011000990139424", "   385200-000-23237",
        ]

        func attributedStringToSpacedString(attributed: NSAttributedString) -> String {
            return attributed.string.enumerated().reduce("") {
                var current = $0 + String($1.element)
                if attributed.attributes(at: $1.offset, effectiveRange: nil)[.kern] != nil {
                    current += " "
                }
                return current
            }
        }

        for ((formatted, type), unformatted) in zip(formatted, unformatted) {
            XCTAssertEqual(formatted, attributedStringToSpacedString(attributed: CreditCardUtils.formattedNumber(number: unformatted, for: type)),
                           "Did not get \"\(formatted)\" when formatting \"\(unformatted)\"")
            XCTAssertEqual(formatted, attributedStringToSpacedString(attributed: CreditCardUtils.formattedNumber(number: unformatted)),
                           "Did not get \"\(formatted)\" when formatting \"\(unformatted)\" without explicitely providing a card type")
            XCTAssertEqual(formatted, attributedStringToSpacedString(attributed: CreditCardUtils.formattedNumber(number: formatted, for: type)),
                           "Formatting formatted \(formatted) did not result in the same formatted number")
        }
    }

    func testCorrectlyCreatesHumanReadableId() throws {
        let numbers = ["378282246310005", "5555555555554444", "379357047249690", "4111111111111111"]

        for number in numbers {
            let creditCard = try CreditCardData(cardNumber: number,
                                                cvv: "123",
                                                expiryMonth: 10,
                                                expiryYear: 50,
                                                country: "DE",
                                                billingData: BillingData())

            switch creditCard.extraAliasInfo {
            case let .creditCard(details):
                XCTAssertEqual(creditCard.cardMask, details.creditCardMask, "The human readable identifier for \(creditCard.cardNumber) should be \(creditCard.cardMask) but is \(details.creditCardMask)")
            default: XCTFail("The credit card extra info should have the .creditCard case")
            }
        }
    }
}
