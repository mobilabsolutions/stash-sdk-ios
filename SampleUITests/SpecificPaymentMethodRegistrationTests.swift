//
//  SpecificPaymentMethodRegistrationTests.swift
//  SampleUITests
//
//  Created by Robert on 24.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import XCTest

class SpecificPaymentMethodRegistrationTests: BaseUITest {
    func testCanRegisterCreditCardDirectly() {
        let app = XCUIApplication()
        showSpecificUI(for: "CC", with: "ADYEN", in: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("4111 1111 1111 1111")

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: "10")
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: "2020")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("737")

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

        let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let alert = springBoard.alerts.containing(NSPredicate(format: "label CONTAINS \"Wants to Use\"")).firstMatch
        XCTAssert(alert.waitForExistence(timeout: 10))
        alert.buttons["Continue"].tap()

        let webViewButton = app.webViews
            .staticTexts["Proceed with Sandbox Purchase"].firstMatch
        XCTAssert(webViewButton.waitForExistence(timeout: 15))
        webViewButton.tap()

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }
}
