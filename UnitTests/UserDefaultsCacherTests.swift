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
    private let expiryDate = Date().addingTimeInterval(10000)

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
        let typeIdentifier = "Type-ID"

        let value = "Hello, world"
        let firstContainer = IdempotencyResultContainer<String, SimpleError>(idempotencyResult: .fulfilled(result: .success(value)),
                                                                             expiry: expiryDate, typeIdentifier: typeIdentifier)
        cacher.cache(firstContainer, for: "First-Idempotency-Key")

        let anotherValue = SimpleError(description: "This is an error")
        let anotherContainer = IdempotencyResultContainer<String, SimpleError>(idempotencyResult: .fulfilled(result: .failure(anotherValue)),
                                                                               expiry: expiryDate, typeIdentifier: typeIdentifier)
        cacher.cache(anotherContainer, for: "Second-Idempotency-Key")

        let thirdContainer = IdempotencyResultContainer<String, SimpleError>(idempotencyResult: .pending,
                                                                             expiry: expiryDate, typeIdentifier: typeIdentifier)
        cacher.cache(thirdContainer, for: "Third-Idempotency-Key")

        let cachedValues = cacher.getCachedValues()

        let firstResult = cachedValues["First-Idempotency-Key"]
        let secondResult = cachedValues["Second-Idempotency-Key"]
        let thirdResult = cachedValues["Third-Idempotency-Key"]

        XCTAssertNotNil(firstResult)
        XCTAssertNotNil(secondResult)
        XCTAssertNotNil(thirdResult)

        if case let .fulfilled(firstFulfilled)? = firstResult?.idempotencyResult {
            switch firstFulfilled {
            case .failure: XCTFail("The first cached value should not correspond to a failure")
            case let .success(successValue): XCTAssertEqual(successValue, value, "The correct value should be returned when caching a successful result")
            }
        } else {
            XCTFail("The first cached value should correspond a fulfilled value")
        }

        if case let .fulfilled(secondFulfilled)? = secondResult?.idempotencyResult {
            switch secondFulfilled {
            case let .failure(error): XCTAssertEqual(error.description, anotherValue.description)
            case .success: XCTFail("The second cached value should not correspond to a success")
            }
        } else {
            XCTFail("The second cached value should correspond a fulfilled value")
        }

        if case .fulfilled? = thirdResult?.idempotencyResult {
            XCTFail("The third cached value should correspond to a pending result")
        }
    }

    func testReplacesCachedValue() throws {
        let key = "First-Idempotency-Key"
        let typeIdentifier = "Type-ID"

        let pendingContainer = IdempotencyResultContainer<String, SimpleError>(idempotencyResult: .pending,
                                                                               expiry: expiryDate, typeIdentifier: typeIdentifier)
        cacher.cache(pendingContainer, for: key)

        let resultValue = "Success result"
        let result = IdempotencyResult<String, SimpleError>.fulfilled(result: Result.success(resultValue))
        let resultContainer = IdempotencyResultContainer(idempotencyResult: result, expiry: expiryDate, typeIdentifier: typeIdentifier)
        cacher.cache(resultContainer, for: key)

        let cachedValues = cacher.getCachedValues()
        XCTAssertNotNil(cachedValues[key])

        if case let .fulfilled(fulfilled)? = cachedValues[key]?.idempotencyResult {
            XCTAssertEqual(try fulfilled.get(), resultValue)
        } else {
            XCTFail("The cached value should be a fulfilled one")
        }
    }

    func testDealsWithLargeNumberOfCachedValues() {
        var keys: Set<String> = []
        let numberOfKeys = 1000
        let typeIdentifier = "Type-ID"

        for _ in 0..<numberOfKeys {
            let key = UUID().uuidString
            keys.insert(key)

            let container = IdempotencyResultContainer<String, SimpleError>(idempotencyResult: .fulfilled(result: .success(key)),
                                                                            expiry: expiryDate,
                                                                            typeIdentifier: typeIdentifier)
            cacher.cache(container, for: key)
        }

        let cachedValues = cacher.getCachedValues()

        XCTAssertNotNil(cachedValues)

        for (key, _) in cachedValues {
            XCTAssertTrue(keys.contains(key))
        }

        XCTAssertEqual(cachedValues.keys.count, numberOfKeys)
    }
}
