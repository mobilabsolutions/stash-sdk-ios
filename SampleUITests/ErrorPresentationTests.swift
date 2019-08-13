//
//  ErrorPresentationTests.swift
//  StashTests
//
//  Created by Robert on 21.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import XCTest

class ErrorPresentationTests: BaseUITest {
    func testPresentsErrorsWhenSkippingFields() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.buttons["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        let numberOfIncorrectCells = collectionViewsQuery.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).allElementsBoundByIndex.count

        XCTAssertGreaterThan(numberOfIncorrectCells, 1,
                             "Expected failure label to exist when adding a SEPA method with invalid number")
    }

    func testHidesErrorWhenAddingCorrectData() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.buttons["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        let previousNumberOfIncorrectCells = collectionViewsQuery.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).allElementsBoundByIndex.count

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE75512108001245126199")

        let currentNumberOfIncorrectCells = collectionViewsQuery.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).allElementsBoundByIndex.count

        XCTAssertGreaterThan(previousNumberOfIncorrectCells, currentNumberOfIncorrectCells, "The error for an incorrect field should disappear after inserting data into that field")
    }

    func testShowsErrorAfterThreeSecondsOfIdleTime() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()

        Thread.sleep(forTimeInterval: 3.05)

        let currentNumberOfIncorrectCells = collectionViewsQuery.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).allElementsBoundByIndex.count

        XCTAssertEqual(currentNumberOfIncorrectCells, 1, "After three seconds, the current idle cell should display an error if the input is incorrect")
    }

    func testShowsMultipleErrorsWhenSkippingDoubleInputCell() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["1234"].tap()

        let numberOfIncorrectCells = collectionViewsQuery.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).allElementsBoundByIndex.count

        XCTAssertEqual(numberOfIncorrectCells, 2,
                       "Expected two failure labels to exist when skipping a double input (first and last name) cell")
    }

    func testShowsAlertBannerWhenUsingBSPayoneNonTestMode() {
        let app = XCUIApplication()
        // Set test mode to false
        app.switches.allElementsBoundByIndex.last?.tap()

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

        collectionViewsQuery.buttons["Country"].tap()
        app.collectionViews.cells.element(boundBy: 4).tap()

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        let alert = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Error")).firstMatch

        waitForElementToAppear(element: alert)
        XCTAssert(alert.exists)
    }

    func testDoesNotStackAlertBanners() {
        let app = XCUIApplication()
        // Set test mode to false
        app.switches.allElementsBoundByIndex.last?.tap()

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

        collectionViewsQuery.buttons["Country"].tap()
        app.collectionViews.cells.element(boundBy: 4).tap()

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        let alert = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Error")).firstMatch

        waitForElementToAppear(element: alert)
        XCTAssert(alert.exists)

        app.buttons["SAVE"].tap()
        XCTAssertFalse(alert.exists)

        waitForElementToAppear(element: alert)
    }

    func testIncorrectAdyenCVVErrorIsShown() {
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
        collectionViewsQuery.textFields["CVV/CVC"].typeText("444")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        let alertText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Error")).firstMatch
        let alertTitle = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "CVC Declined")).firstMatch

        waitForElementToAppear(element: alertTitle)
        XCTAssert(alertText.exists)
        XCTAssert(alertTitle.exists)
    }
}
