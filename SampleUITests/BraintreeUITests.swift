//
//  BraintreeUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import XCTest

class BraintreeUITests: BaseUITest {
    func testLoadingViewIsShownForPayPalRegistration() {
        let app = XCUIApplication()
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
        payPalCell.tap()

        XCTAssertTrue(app.activityIndicators.element.exists, "Expected activity indicator to exist for loading view for PayPal registration")
    }

    func testPayPalViewIsShown() {
        let app = XCUIApplication()

        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
        payPalCell.tap()

        let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let alert = springBoard.alerts.containing(NSPredicate(format: "label CONTAINS \"Wants to Use\"")).firstMatch
        XCTAssert(alert.waitForExistence(timeout: 10))
        alert.buttons["Continue"].tap()

        self.waitForElementToAppear(element: app.buttons.firstMatch, timeout: 10)
    }

    func testPayPalViewCanBeCancelled() {
        let app = XCUIApplication()

        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
        payPalCell.tap()

        let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let alert = springBoard.alerts.firstMatch
        XCTAssert(alert.waitForExistence(timeout: 10))
        alert.buttons["Cancel"].tap()

        self.waitForElementToAppear(element: payPalCell, timeout: 10)
        XCTAssertTrue(payPalCell.exists, "Expected to return to main payment method screen")
    }
}
