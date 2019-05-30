//
//  SpecificPaymentMethodRegistrationTests.swift
//  SampleUITests
//
//  Created by Robert on 24.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class SpecificPaymentMethodRegistrationTests: BaseUITest {
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    func testCanRegisterCreditCardDirectly() {
        let app = XCUIApplication()
        showSpecificUI(for: "CC", in: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("4111 1111 1111 1111")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("444")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 4).tap()

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testCanRegisterSEPADirectly() {
        let app = XCUIApplication()
        showSpecificUI(for: "SEPA", in: app)

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE92123456789876543210")

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Bertram")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Schneider")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 5).tap()

        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testCanRegisterPayPalDirectly() {
        let app = XCUIApplication()
        showSpecificUI(for: "PayPal", in: app)

        var hasDismissedSystemAlert = false
        let handler = addUIInterruptionMonitor(withDescription: "System Alert") {
            (alert) -> Bool in

            // Click the first button in dialog
            let button = alert.buttons.element(boundBy: 1)
            if button.exists {
                button.tap()
            }

            hasDismissedSystemAlert = true
            return true
        }

        expectation(for: NSPredicate { _, _ in
            XCUIApplication().tap() // this is the magic tap that makes it work
            return hasDismissedSystemAlert
        }, evaluatedWith: NSNull(), handler: nil)

        self.waitForExpectations(timeout: 10.0, handler: nil)
        removeUIInterruptionMonitor(handler)

        app.webViews.staticTexts["Proceed with Sandbox Purchase"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    private func showSpecificUI(for paymentMethodType: String, in app: XCUIApplication) {
        app.tabBars.buttons["Bookmarks"].tap()
        app.segmentedControls.buttons[paymentMethodType].tap()
        app.buttons["Show Specific UI"].tap()
    }
}
