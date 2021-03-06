//
//  AdyenUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import XCTest

class AdyenUITests: BaseUITest {
    func DISABLED_testCanCreateCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("2222 4000 1000 0008")

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: "10")
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: "2020")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("737")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch, timeout: 10)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func DISABLED_testCanCreateCreditCardWith3DS1() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("6731 0123 4567 8906")

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: "10")
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: "2020")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("737")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.buttons["Submit"], timeout: 10)

        let usernameTextField = app.webViews.textFields.firstMatch
        usernameTextField.tap()
        usernameTextField.typeText("user")

        let passwordTextField = app.webViews.secureTextFields.firstMatch
        passwordTextField.tap()
        passwordTextField.typeText("password")

        app.buttons["Submit"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch, timeout: 10)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func DISABLED_testCanCreateCreditCardWith3DS2() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("5454 5454 5454 5454")

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: "10")
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: "2020")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("737")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.buttons["Submit"].firstMatch, timeout: 10)

        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText("1234")

        app.buttons["Submit"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch, timeout: 10)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func DISABLED_testCanCreateSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", with: "ADYEN", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE75512108001245126199")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch, timeout: 10)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testHasCorrectFieldsForSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", with: "ADYEN", app: app)

        let expectedCells = ["First Name", "IBAN"]

        let cells = app.collectionViews.cells

        waitForElementToAppear(element: cells.staticTexts["First Name"])

        XCTAssertEqual(cells.count, expectedCells.count, "Adyen SEPA should have \(expectedCells.count) cells but has \(cells.count)")

        for expectedTitle in expectedCells {
            XCTAssertTrue(cells.staticTexts[expectedTitle].exists, "Cell with title \"\(expectedTitle)\" should exist")
        }
    }

    func testHasCorrectFieldsForCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        let expectedCells = [["First Name", "Last Name"], ["Credit Card Number"], ["Expiration date", "CVV/CVC"]]
        let cells = app.collectionViews.cells

        waitForElementToAppear(element: cells.staticTexts["Credit Card Number"])

        XCTAssertEqual(cells.count, expectedCells.count, "Adyen Credit Card should have \(expectedCells.count) cells but has \(cells.count)")

        for expectedTitle in expectedCells.flatMap({ $0 }) {
            XCTAssertTrue(cells.staticTexts[expectedTitle].exists, "Cell with title \"\(expectedTitle)\" should exist")
        }
    }
}
