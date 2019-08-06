//
//  SEPADataTests.swift
//  StashTests
//
//  Created by Robert on 13.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@testable import StashCore
import XCTest

class SEPADataTests: XCTestCase {
    func testCorrectlyCleansNumbers() {
        let cleanNumbers = ["DE75512108001245126199", "DE75512108001245126199", "BA393385804800211234", "AT483200000012345864"]
        let uncleanNumbers = ["DE7551 2108001 245126 199", "de7 5-512-1080-0124-5126-199", "ba393-385-804-800-211-234", " aT48 32000 000123 45864"]

        for (cleanNumber, uncleanNumber) in zip(cleanNumbers, uncleanNumbers) {
            XCTAssertEqual(cleanNumber, SEPAUtils.cleanedIban(number: uncleanNumber), "Formatting \(uncleanNumber) should result in \(cleanNumber)")
            XCTAssertEqual(cleanNumber, SEPAUtils.cleanedIban(number: cleanNumber), "Formatting clean number \(cleanNumber) should not change it")
        }
    }

    func testCorrectlyValidatesNumbers() {
        let validNumbers = ["DE75512108001245126199", "DE75512108001245126199", "BA393385804800211234", "AT483200000012345864",
                            "CY21002001950000357001234567", "SV43ACAT00000000000000123123"]
        let invalidNumbers = ["DE75534348001245126145", "DE75512108001245134199", "BA344385804800211454", "AT483200000012245894",
                              "DE7551210800124512619", "SV75512108001245126199"]

        for valid in validNumbers {
            XCTAssertTrue(SEPAUtils.isValid(cleanedNumber: valid), "\(valid) should be a valid IBAN")
        }

        for invalid in invalidNumbers {
            XCTAssertFalse(SEPAUtils.isValid(cleanedNumber: invalid), "\(invalid) should be an invalid IBAN")
        }
    }

    func testCorrectlyFormatsIban() {
        func attributedStringToSpacedString(attributed: NSAttributedString) -> String {
            return attributed.string.enumerated().reduce("") {
                var current = $0 + String($1.element)
                if attributed.attributes(at: $1.offset, effectiveRange: nil)[.kern] != nil {
                    current += " "
                }
                return current
            }
        }

        let formatted = ["DE75 5121 0800 1245 1261 99", "DE75 5121 0800 1245 1261 99", "BA39 3385 8048 0021 1234", "AT48 3200 0000 1234 5864",
                         "CY21 0020 0195 0000 3570 0123 4567", "SV43 ACAT 0000 0000 0000 0012 3123"]
        let unformatted = ["DE7 551 210 80012 45126 199", "D E7 55 121080 01245126199", "BA393385804800211234", "AT483200000012345864",
                           "CY21002001950000357001234567", "SV43ACAT00000000000000123123"]

        for (current, expected) in zip(unformatted, formatted) {
            XCTAssertEqual(attributedStringToSpacedString(attributed: SEPAUtils.formattedIban(number: current)), expected,
                           "Formatting \(current) should result in \(expected)")
            XCTAssertEqual(attributedStringToSpacedString(attributed: SEPAUtils.formattedIban(number: expected)), expected,
                           "Formatting formatted number \(expected) should not change it")
        }
    }

    func testCorrectlyCreatesMaskedIban() throws {
        let numbers = ["DE75512108001245126199", "DE75512108001245126199", "BA393385804800211234", "AT483200000012345864",
                       "CY21002001950000357001234567", "SV43ACAT00000000000000123123"]
        let formattedNumbers = ["DEXX XXXX XXXX XXXX XX6199", "DEXX XXXX XXXX XXXX XX6199", "BAXX XXXX XXXX XXXX 1234", "ATXX XXXX XXXX XXXX 5864",
                                "CYXX XXXX XXXX XXXX XXXX XXXX 4567", "SVXX XXXX XXXX XXXX XXXX XXXX 3123"]

        for (number, formatted) in zip(numbers, formattedNumbers) {
            let sepa = try SEPAData(iban: number, bic: nil, billingData: BillingData())

            switch sepa.extraAliasInfo {
            case let .sepa(details):
                XCTAssertEqual(formatted, details.maskedIban, "The human readable identifier should be equal to the masked IBAN but is instead \(details.maskedIban)")
            default: XCTFail("The SEPA extra alias info should be of the .sepa case")
            }
        }
    }
}
