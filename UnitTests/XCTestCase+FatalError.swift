//
//  XCTestCase+FatalError.swift
//  MobilabPaymentTests
//
//  Created by Borna Beakovic on 22/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
@testable import MobilabPaymentCore
import XCTest

extension XCTestCase {
    func expectFatalError(testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String?

        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)

        waitForExpectations(timeout: 2) { _ in
            XCTAssertNotNil(assertionMessage)

            FatalErrorUtil.restoreFatalError()
        }
    }

    func notExpectFatalError(testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "notExpectingFatalError")
        expectation.isInverted = true
        var assertionMessage: String?

        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)

        waitForExpectations(timeout: 2) { _ in
            XCTAssertNil(assertionMessage)

            FatalErrorUtil.restoreFatalError()
        }
    }

    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while true
    }
}
