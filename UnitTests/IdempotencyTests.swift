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

        typealias Value = IdempotencyResultContainer<T, U>
        typealias Key = String

        private var cachedValues: [String: IdempotencyResultContainer<T, U>]

        init(cachedValues: [String: IdempotencyResultContainer<T, U>]) {
            self.cachedValues = cachedValues
        }

        func cache(_: IdempotencyResultContainer<T, U>, for _: String) {
            // Intentionally empty
        }

        func getCachedValues() -> [String: IdempotencyResultContainer<T, U>] {
            return self.cachedValues
        }

        func purgeExpiredValues() {
            self.cachedValues = self.cachedValues.filter { _, value in
                currentDateProvider.flatMap { $0.currentDate < value.expiry } ?? true
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

    func testCorrectlyHandlesMultipleDifferentIdempotencyKeys() throws {
        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if every key is only called once")
        doesNotUseEnqueueableClosure.isInverted = true

        let typeIdentifier = PaymentMethodType.creditCard.rawValue

        let keys = ["1", "2", "3", "4", "5"]
        for key in keys {
            let result = try manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
                doesNotUseEnqueueableClosure.fulfill()
            }, typeIdentifier: typeIdentifier)

            XCTAssertNil(result, "There should not be a result when calling with a key for the first time")
        }

        for key in keys {
            self.manager.setAndEndIdempotencyHandling(result: .success(self.createSuccessMessage(for: key)), for: key)
        }

        for key in keys {
            let result = try manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
                doesNotUseEnqueueableClosure.fulfill()
            }, typeIdentifier: typeIdentifier)

            XCTAssertNotNil(result, "There should be a result when calling the idempotency mechanism for the second time")

            guard let existingResult = result
            else { continue }

            switch existingResult {
            case .pending: XCTFail("After the result has been set for a key, it should not return a pending result")
            case let .fulfilled(result):
                guard case let .success(successMessage) = result
                else { XCTFail("The provided result should be successful"); continue }

                XCTAssertEqual(successMessage, self.createSuccessMessage(for: key))
            }
        }

        wait(for: [doesNotUseEnqueueableClosure], timeout: 0.5)
    }

    func testCorrectlyHandlesMultipleThreads() throws {
        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if every key is only called once")
        doesNotUseEnqueueableClosure.isInverted = true

        let typeIdentifier = PaymentMethodType.creditCard.rawValue

        let numberOfThreads = 100

        let allThreadsEnd = XCTestExpectation(description: "Every thread should get a result")
        allThreadsEnd.expectedFulfillmentCount = numberOfThreads

        let keys = Array(repeating: { UUID().uuidString }, count: numberOfThreads).map { $0() }
        for key in keys {
            let thread = Thread {
                let result = try? self.manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
                    doesNotUseEnqueueableClosure.fulfill()
                }, typeIdentifier: typeIdentifier)

                XCTAssertNil(result)
                self.manager.setAndEndIdempotencyHandling(result: .success(self.createSuccessMessage(for: key)), for: key)

                Thread.sleep(forTimeInterval: 0.2)

                let fulfilledResult = try? self.manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
                    doesNotUseEnqueueableClosure.fulfill()
                }, typeIdentifier: typeIdentifier)

                XCTAssertNotNil(fulfilledResult, "After a result has been set for a key, it should also be returned")

                if let fulfilled = fulfilledResult,
                    case let .fulfilled(returningResult) = fulfilled,
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

        let typeIdentifier = PaymentMethodType.creditCard.rawValue

        let usesEnqueueableClosure = self.expectation(description: "The idempotency handling should use the enqueued closure when a key request happens more than once")
        usesEnqueueableClosure.expectedFulfillmentCount = numberOfThreads - 1

        for _ in 0..<numberOfThreads {
            let thread = Thread {
                _ = try? self.manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { result in
                    switch result {
                    case .failure: XCTFail("Should return a successful response when the result is set and is also successful")
                    case let .success(message): XCTAssertEqual(message, successResultString)
                    }

                    usesEnqueueableClosure.fulfill()
                }, typeIdentifier: typeIdentifier)
            }

            thread.start()
        }

        // Wait until _after_ all threads have been created and have gotten the idempotency result
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            self.manager.setAndEndIdempotencyHandling(result: .success(successResultString), for: key)
        }

        wait(for: [usesEnqueueableClosure], timeout: 5)
    }

    func testCorrectlyHandlesPendingCachedValues() throws {
        let pendingKey = "Pending-Cached-Key"
        let expiryDate = Date().addingTimeInterval(10000)
        let cacher = NoCacher<String, CodableError>(cachedValues: [pendingKey: IdempotencyResultContainer(idempotencyResult: .pending, expiry: expiryDate, typeIdentifier: PaymentMethodType.creditCard.rawValue)])
        self.manager = IdempotencyManager<String, CodableError, NoCacher<String, CodableError>>(cacher: cacher)

        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if the key is cached")
        doesNotUseEnqueueableClosure.isInverted = true

        let result = try self.manager.getIdempotencyResultOrStartSession(for: pendingKey, potentiallyEnqueueing: { _ in
            doesNotUseEnqueueableClosure.fulfill()
        }, typeIdentifier: PaymentMethodType.creditCard.rawValue)

        XCTAssertNotNil(result)

        if case let .fulfilled(fulfilledResult)? = result {
            switch fulfilledResult {
            case .success: XCTFail("A pending result should be treated as a failure")
            case .failure: break
            }
        } else {
            XCTFail("If a value is cached as pending on creation of the cacher, it should be handled as an error that happened before the application quit")
        }

        wait(for: [doesNotUseEnqueueableClosure], timeout: 0.5)
    }

    func testCorrectlyThrowsExceptionWhenDifferentTypeIsUsed() throws {
        let doesNotUseEnqueueableClosure = XCTestExpectation(description: "The idempotency handling should not use the enqueued closure if every key is only called once")
        doesNotUseEnqueueableClosure.isInverted = true

        let key = UUID().uuidString
        let firstTypeIdentifier = PaymentMethodType.creditCard.rawValue
        let secondTypeIdentifier = PaymentMethodType.sepa.rawValue

        let result = try manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
            doesNotUseEnqueueableClosure.fulfill()
        }, typeIdentifier: firstTypeIdentifier)

        XCTAssertNil(result)

        do {
            _ = try self.manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
                doesNotUseEnqueueableClosure.fulfill()
            }, typeIdentifier: secondTypeIdentifier)

            XCTFail("An error should be thrown when the type identifier does not match up")
        } catch {
            // Intentionally empty
        }

        self.manager.setAndEndIdempotencyHandling(result: .success("Success Value"), for: key)

        // Make sure that the error is still thrown after the result is fulfilled.
        do {
            _ = try self.manager.getIdempotencyResultOrStartSession(for: key, potentiallyEnqueueing: { _ in
                doesNotUseEnqueueableClosure.fulfill()
            }, typeIdentifier: secondTypeIdentifier)

            XCTFail("An error should be thrown when the type identifier does not match up")
        } catch {
            // Intentionally empty
        }
    }

    private func createSuccessMessage(for key: String) -> String {
        return "Success-Key-\(key)"
    }
}
