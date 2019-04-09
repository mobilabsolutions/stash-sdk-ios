//
//  AdyenUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class AdyenUITests: BaseUITest {
    #warning("Implement this test")
    func testCanCreateCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)
    }

    #warning("Implement this test")
    func testCanCreateSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", with: "ADYEN", app: app)
    }

    func testHasCorrectFieldsForSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", with: "ADYEN", app: app)

        let expectedCells = ["Name", "IBAN"]

        let cells = app.collectionViews.cells

        waitForElementToAppear(element: cells.staticTexts["Name"])

        XCTAssertEqual(cells.count, expectedCells.count, "Adyen SEPA should have \(expectedCells.count) cells but has \(cells.count)")

        for expectedTitle in expectedCells {
            XCTAssertTrue(cells.staticTexts[expectedTitle].exists, "Cell with title \"\(expectedTitle)\" should exist")
        }
    }

    func testHasCorrectFieldsForCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)

        let expectedCells = [["Credit card number"], ["Expiration date", "CVV"]]
        let cells = app.collectionViews.cells

        waitForElementToAppear(element: cells.staticTexts["Credit card number"])

        XCTAssertEqual(cells.count, expectedCells.count, "Adyen Credit Card should have \(expectedCells.count) cells but has \(cells.count)")

        for expectedTitle in expectedCells.flatMap({ $0 }) {
            XCTAssertTrue(cells.staticTexts[expectedTitle].exists, "Cell with title \"\(expectedTitle)\" should exist")
        }
    }
}
