//
//  BSPayoneUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class BSPayoneUITests: BaseUITest {
    func testCanAddSepaMethod() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE75512108001245126199")

        collectionViewsQuery.textFields["XXX"].tap()
        collectionViewsQuery.textFields["XXX"].typeText("COLSDE33XXX")

        app.collectionViews.firstMatch.tap()
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testCanAddCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("4111 1111 1111 1111")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["CVV"].tap()
        collectionViewsQuery.textFields["CVV"].typeText("123")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testFailsForLiveMode() {
        let app = XCUIApplication()
        app.tabBars.buttons["Bookmarks"].tap()

        guard let testModeSwitch = app.switches.allElementsBoundByIndex.last,
            testModeSwitch.value as? String == "1"
        else { XCTFail("Test Mode switch should exist and be enabled"); return }

        testModeSwitch.tap()

        app.buttons["Trigger Register UI"].tap()

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts["Credit Card"].tap()

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("4111 1111 1111 1111")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["CVV"].tap()
        collectionViewsQuery.textFields["CVV"].typeText("123")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Error"))
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }
}
