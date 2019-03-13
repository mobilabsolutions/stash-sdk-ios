//
//  CreditCardDataTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import XCTest

class CreditCardDataTests: XCTestCase {
    func testCorrectlyParsesCardMask() {
        let first = CreditCardData(cardNumber: "4111 1111 1111 1111", cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
        XCTAssertEqual(first.cardMask, 1111, "Card mask should equal last four digits of card number")

        let second = CreditCardData(cardNumber: "5500 0000 0000 0004", cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
        XCTAssertEqual(second.cardMask, 4, "Card mask should equal last four digits of card number")
    }

    func testCorrectlyParsesCardType() {
        let exampleNumbers: [(String, CreditCardData.CreditCardType)] = [
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
        ]

        for (number, type) in exampleNumbers {
            let card = CreditCardData(cardNumber: number, cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
            print("Card \(number) has type \(card.cardType)")
            XCTAssertEqual(card.cardType, type, "Card \(number) should have type \(type) but has type \(card.cardType)")
        }
    }
}
