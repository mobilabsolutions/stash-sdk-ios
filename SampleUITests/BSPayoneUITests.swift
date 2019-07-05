//
//  BSPayoneUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
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

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

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

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("123")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

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

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("123")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Error")).firstMatch)
    }

    func testCountrySelectionSearchFieldPresent() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Country"].tap()

        let view = app.otherElements["CountrySelectionView"]
        let searchView = view.otherElements["SearchView"]
        XCTAssertNotNil(searchView.textFields["Search Country"])
    }

    func testCountryScreenDataPresent() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Country"].tap()

        XCTAssertTrue(collectionViewsQuery.cells.count > 0)
    }

    func testCountryCurrentLocationDisplaysLastSearchedCountry() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Country"].tap()

        let view = app.otherElements["CountrySelectionView"]

        let searchView = view.otherElements["SearchView"]
        searchView.textFields["Search Country"].tap()
        searchView.textFields["Search Country"].typeText("Zimbabwe")

        let firstChild = view.collectionViews.children(matching: .cell).element(boundBy: 0)
        let label = firstChild.staticTexts["Zimbabwe"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(view.collectionViews.cells.count == 1) // should be only one entry with the searched country name

        view.collectionViews.staticTexts["Zimbabwe"].tap() // goes back to previous screen

        expectation(for: exists, evaluatedWith: collectionViewsQuery.textFields["Country"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        collectionViewsQuery.textFields["Country"].tap() // previous screen

        XCTAssertNotNil(view.collectionViews.cells.staticTexts["Zimbabwe"]) // current location contains last selected country name
    }
}
