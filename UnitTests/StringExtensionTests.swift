//
//  StringExtensionTests.swift
//  MobilabPaymentCore
//
//  Created by Robert on 13.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class StringExtensionTests: XCTest {
    func testComputesBase64() {
        let input = "This is a test string for testing base64"
        let expected = "VGhpcyBpcyBhIHRlc3Qgc3RyaW5nIGZvciB0ZXN0aW5nIGJhc2U2NA=="

        XCTAssertEqual(input.toBase64(), expected)
    }

    func testIsAlphanumeric() {
        XCTAssertTrue("hello".isAlphaNumeric)
        XCTAssertTrue("hello123".isAlphaNumeric)
        XCTAssertTrue("DEABCDE123KKJKJ1234ii".isAlphaNumeric)
        XCTAssertTrue("112233".isAlphaNumeric)

        XCTAssertFalse("Hello, world".isAlphaNumeric)
        XCTAssertFalse("Test test".isAlphaNumeric)
        XCTAssertFalse("Test!".isAlphaNumeric)
        XCTAssertFalse("hèllo".isAlphaNumeric)
        XCTAssertFalse("🙂".isAlphaNumeric)
    }
}
