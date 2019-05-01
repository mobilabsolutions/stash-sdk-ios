//
//  IdempotencyTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 26.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class IdempotencyTests: XCTestCase {
    private class NoCacher<T: Codable, U: Error & Codable>: Cacher {
        var currentDateProvider: DateProviding?

        typealias Value = IdempotencyResult<T, U>
        typealias Key = String

        private var cachedValues: [String: IdempotencyResult<T, U>]

        init(cachedValues: [String: IdempotencyResult<T, U>]) {
            self.cachedValues = cachedValues
        }

        func cache(_: IdempotencyResult<T, U>, for _: String) {
            // Intentionally empty
        }

        func getCachedValues() -> [String: IdempotencyResult<T, U>] {
            return self.cachedValues
        }

        func purgeExpiredValues() {
            self.cachedValues = self.cachedValues.filter {
                switch $0.value {
                case let .pending(expiry): fallthrough
                case let .fulfilled(_, expiry): return currentDateProvider.flatMap { $0.currentDate < expiry } ?? true
                }
            }
        }
    }

    private struct CodableError: Error, Codable, IdempotencyApplicationFailureProviding {
        static func createErrorForPendingRequestSinceLastStart() -> IdempotencyTests.CodableError {
            return CodableError()
        }
    }

    private var manager: IdempotencyManager<String, CodableError, NoCacher<String, CodableError>>!

    override func setUp() {
        self.manager = IdempotencyManager<String, CodableError, NoCacher<String, CodableError>>(cacher: NoCacher(cachedValues: [:]))
    }

    func testCorrectlyHandlesMultipleDifferentIdempotencyKeys() {
        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if every key is only called once")
        doesNotUseEnqueueableClosure.isInverted = true

        let keys = ["1", "2", "3", "4", "5"]
        for key in keys {
            let result = manager.getIdempotencyResultOrStartSession(for: key) { _ in
                doesNotUseEnqueueableClosure.fulfill()
            }

            XCTAssertNil(result, "There should not be a result when calling with a key for the first time")
        }

        for key in keys {
            self.manager.setAndEndIdempotencyHandling(result: .success(self.createSuccessMessage(for: key)), for: key)
        }

        for key in keys {
            let result = manager.getIdempotencyResultOrStartSession(for: key) { _ in
                doesNotUseEnqueueableClosure.fulfill()
            }

            XCTAssertNotNil(result, "There should be a result when calling the idempotency mechanism for the second time")

            guard let existingResult = result
            else { continue }

            switch existingResult {
            case .pending: XCTFail("After the result has been set for a key, it should not return a pending result")
            case let .fulfilled(result, _):
                guard case let .success(successMessage) = result
                else { XCTFail("The provided result should be successful"); continue }

                XCTAssertEqual(successMessage, self.createSuccessMessage(for: key))
            }
        }

        wait(for: [doesNotUseEnqueueableClosure], timeout: 0.5)
    }

    func testCorrectlyHandlesMultipleThreads() {
        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if every key is only called once")
        doesNotUseEnqueueableClosure.isInverted = true

        let numberOfThreads = 100

        let allThreadsEnd = XCTestExpectation(description: "Every thread should get a result")
        allThreadsEnd.expectedFulfillmentCount = numberOfThreads

        let keys = Array(repeating: { UUID().uuidString }, count: numberOfThreads).map { $0() }
        for key in keys {
            let thread = Thread {
                let result = self.manager.getIdempotencyResultOrStartSession(for: key) { _ in
                    doesNotUseEnqueueableClosure.fulfill()
                }

                XCTAssertNil(result)
                self.manager.setAndEndIdempotencyHandling(result: .success(self.createSuccessMessage(for: key)), for: key)

                Thread.sleep(forTimeInterval: 0.2)

                let fulfilledResult = self.manager.getIdempotencyResultOrStartSession(for: key) { _ in
                    doesNotUseEnqueueableClosure.fulfill()
                }

                XCTAssertNotNil(fulfilledResult, "After a result has been set for a key, it should also be returned")

                if let fulfilled = fulfilledResult,
                    case let .fulfilled(returningResult, _) = fulfilled,
                    case let .success(successMessage) = returningResult {
                    XCTAssertEqual(successMessage, self.createSuccessMessage(for: key))
                } else {
                    XCTFail("After a result has been set, the returned idempotency result should be fulfilled")
                }

                allThreadsEnd.fulfill()
            }

            thread.start()
        }

        wait(for: [doesNotUseEnqueueableClosure, allThreadsEnd], timeout: 5)
    }

    func testCorrectlyHandlesMultipleThreadsForSameKey() {
        let key = "Test-Key"
        let numberOfThreads = 100
        let successResultString = "Success"

        let usesEnqueueableClosure = self.expectation(description: "The idempotency handling should use the enqueued closure when a key request happens more than once")
        usesEnqueueableClosure.expectedFulfillmentCount = numberOfThreads - 1

        for _ in 0..<numberOfThreads {
            let thread = Thread {
                _ = self.manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { result in
                    switch result {
                    case .failure: XCTFail("Should return a successful response when the result is set and is also successful")
                    case let .success(message): XCTAssertEqual(message, successResultString)
                    }

                    usesEnqueueableClosure.fulfill()
                })
            }

            thread.start()
        }

        // Wait until _after_ all threads have been created and have gotten the idempotency result
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            self.manager.setAndEndIdempotencyHandling(result: .success(successResultString), for: key)
        }

        wait(for: [usesEnqueueableClosure], timeout: 5)
    }

    func testCorrectlyHandlesPendingCachedValues() {
        let pendingKey = "Pending-Cached-Key"
        let expiryDate = Date().addingTimeInterval(10000)
        let cacher = NoCacher<String, CodableError>(cachedValues: [pendingKey: .pending(expiry: expiryDate)])
        self.manager = IdempotencyManager<String, CodableError, NoCacher<String, CodableError>>(cacher: cacher)

        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if the key is cached")
        doesNotUseEnqueueableClosure.isInverted = true

        let result = self.manager.getIdempotencyResultOrStartSession(for: pendingKey) { _ in
            doesNotUseEnqueueableClosure.fulfill()
        }

        XCTAssertNotNil(result)

        if case let .fulfilled(fulfilledResult, _)? = result {
            switch fulfilledResult {
            case .success: XCTFail("A pending result should be treated as a failure")
            case .failure: break
            }
        } else {
            XCTFail("If a value is cached as pending on creation of the cacher, it should be handled as an error that happened before the application quit")
        }

        wait(for: [doesNotUseEnqueueableClosure], timeout: 0.5)
    }

    private func createSuccessMessage(for key: String) -> String {
        return "Success-Key-\(key)"
    }
}
