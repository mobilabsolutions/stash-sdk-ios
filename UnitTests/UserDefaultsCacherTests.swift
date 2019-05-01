//
//  UserDefaultsCacherTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 01.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class UserDefaultsCacherTests: XCTestCase {
    private var cacher: IdempotencyResultUserDefaultsCacher<String, SimpleError>!

    private struct SimpleError: Error, Codable {
        let description: String
    }

    override func setUp() {
        super.setUp()
        self.cacher = IdempotencyResultUserDefaultsCacher(suiteIdentifier: "idempotency-userdefaults-cacher-tests")
    }

    override func tearDown() {
        super.tearDown()

        guard let userDefaults = UserDefaults(suiteName: "idempotency-userdefaults-cacher-tests")
        else { return }

        for entry in userDefaults.dictionaryRepresentation() {
            userDefaults.removeObject(forKey: entry.key)
        }
    }

    func testCorrectlyCachesSimpleValue() {
        let value = "Hello, world"
        cacher.cache(.fulfilled(result: .success(value)), for: "First-Idempotency-Key")

        let anotherValue = SimpleError(description: "This is an error")
        cacher.cache(.fulfilled(result: .failure(anotherValue)), for: "Second-Idempotency-Key")

        cacher.cache(.pending, for: "Third-Idempotency-Key")

        let cachedValues = cacher.getCachedValues()

        let firstResult = cachedValues["First-Idempotency-Key"]
        let secondResult = cachedValues["Second-Idempotency-Key"]
        let thirdResult = cachedValues["Third-Idempotency-Key"]

        XCTAssertNotNil(firstResult)
        XCTAssertNotNil(secondResult)
        XCTAssertNotNil(thirdResult)

        if case let .fulfilled(firstFulfilled)? = firstResult {
            switch firstFulfilled {
            case .failure: XCTFail("The first cached value should not correspond to a failure")
            case let .success(successValue): XCTAssertEqual(successValue, value, "The correct value should be returned when caching a successful result")
            }
        } else {
            XCTFail("The first cached value should correspond a fulfilled value")
        }

        if case let .fulfilled(secondFulfilled)? = secondResult {
            switch secondFulfilled {
            case let .failure(error): XCTAssertEqual(error.description, anotherValue.description)
            case .success: XCTFail("The second cached value should not correspond to a success")
            }
        } else {
            XCTFail("The second cached value should correspond a fulfilled value")
        }

        if case .fulfilled? = thirdResult {
            XCTFail("The third cached value should correspond to a pending result")
        }
    }

    func testReplacesCachedValue() throws {
        let key = "First-Idempotency-Key"
        cacher.cache(.pending, for: key)

        let resultValue = "Success result"
        let result = IdempotencyResult<String, SimpleError>.fulfilled(result: Result.success(resultValue))
        cacher.cache(result, for: key)

        let cachedValues = cacher.getCachedValues()
        XCTAssertNotNil(cachedValues[key])

        if case let .fulfilled(fulfilled)? = cachedValues[key] {
            XCTAssertEqual(try fulfilled.get(), resultValue)
        } else {
            XCTFail("The cached value should be a fulfilled one")
        }
    }

    func testDealsWithLargeNumberOfCachedValues() {
        var keys: Set<String> = []
        let numberOfKeys = 1000

        for _ in 0..<numberOfKeys {
            let key = UUID().uuidString
            keys.insert(key)

            cacher.cache(.fulfilled(result: .success(key)), for: key)
        }

        let cachedValues = cacher.getCachedValues()

        XCTAssertNotNil(cachedValues)

        for (key, _) in cachedValues {
            XCTAssertTrue(keys.contains(key))
        }

        XCTAssertEqual(cachedValues.keys.count, numberOfKeys)
    }
}
