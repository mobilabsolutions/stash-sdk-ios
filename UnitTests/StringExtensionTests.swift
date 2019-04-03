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

        XCTAssertEqual(input.toBase64(), expected, "Expected \(expected) when base64-ing \(input)")
    }

    func testIsAlphanumeric() {
        XCTAssertTrue("hello".isAlphaNumeric, "\"hello\" should be alphanumeric")
        XCTAssertTrue("hello123".isAlphaNumeric, "\"hello123\" should be alphanumeric")
        XCTAssertTrue("DEABCDE123KKJKJ1234ii".isAlphaNumeric, "\"DEABCDE123KKJKJ1234ii\" should be alphanumeric")
        XCTAssertTrue("112233".isAlphaNumeric, "\"112233\" should be alphanumeric")

        XCTAssertFalse("Hello, world".isAlphaNumeric, "\"Hello, world\" should not be alphanumeric")
        XCTAssertFalse("Test test".isAlphaNumeric, "\"Test test\" should not be alphanumeric")
        XCTAssertFalse("Test!".isAlphaNumeric, "\"Test!\" should not be alphanumeric")
        XCTAssertFalse("hèllo".isAlphaNumeric, "\"hèllo\" should not be alphanumeric")
        XCTAssertFalse("🙂".isAlphaNumeric, "\"🙂\" should not be alphanumeric")
    }
}
