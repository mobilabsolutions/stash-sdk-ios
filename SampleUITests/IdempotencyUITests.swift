//
//  IdempotencyUITests.swift
//  SampleUITests
//
//  Created by Robert on 31.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class IdempotencyUITests: BaseUITest {
    func testDoesCorrectlyHandleSameIdempotencyKeyForSuccess() {
        let app = XCUIApplication()

        let idempotencyKey = UUID().uuidString

        app.textFields["Idempotency Key"].tap()
        app.textFields["Idempotency Key"].typeText(idempotencyKey + "\n")
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("4000 0200 0000 0000")

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: "10")
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: "2020")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("737")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssert(app.alerts.firstMatch.waitForExistence(timeout: 15))

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()

        // The alert should be immediately shown when the register using UI method is called.
        showSpecificUI(for: "CC", in: app)
        waitForElementToAppear(element: app.alerts.firstMatch)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when retrying a valid idempotency request")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testDoesCorrectlyHandleSameIdempotencyKeyForClose() {
        let app = XCUIApplication()

        let idempotencyKey = UUID().uuidString

        app.textFields["Idempotency Key"].tap()
        app.textFields["Idempotency Key"].typeText(idempotencyKey + "\n")
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        app.buttons["Back"].tap()
        app.navigationBars.buttons.firstMatch.tap()

        // The alert should be immediately shown when the register using UI method is called.
        showSpecificUI(for: "CC", in: app)
        waitForElementToAppear(element: app.alerts.firstMatch)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Error"),
                      "Expected \"Error\" text in the app alert when retrying an errored idempotency request")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }
}
