//
//  SEPADataTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 13.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class SEPADataTests: XCTestCase {
    func testCorrectlyCleansNumbers() {
        let cleanNumbers = ["DE75512108001245126199", "DE75512108001245126199", "BA393385804800211234", "AT483200000012345864"]
        let uncleanNumbers = ["DE7551 2108001 245126 199", "de7 5-512-1080-0124-5126-199", "ba393-385-804-800-211-234", " aT48 32000 000123 45864"]

        for (cleanNumber, uncleanNumber) in zip(cleanNumbers, uncleanNumbers) {
            XCTAssertEqual(cleanNumber, SEPAUtils.cleanedIban(number: uncleanNumber))
            XCTAssertEqual(cleanNumber, SEPAUtils.cleanedIban(number: cleanNumber))
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
}
