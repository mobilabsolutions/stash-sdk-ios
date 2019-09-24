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

        XCTAssertTrue(app.images.firstMatch.exists, "Expected image view exists for loading view for PayPal registration")
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
        XCTAssert(alert.waitForExistence(timeout: 15))
        alert.buttons["Cancel"].tap()

        self.waitForElementToAppear(element: payPalCell, timeout: 10)
        XCTAssertTrue(payPalCell.exists, "Expected to return to main payment method screen")
    }

    func testCanCreateCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "BRAINTREE", app: app)

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Xx")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Xx")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("378282246310005")

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: "10")
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: "2020")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("1234")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch, timeout: 20)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }
}
