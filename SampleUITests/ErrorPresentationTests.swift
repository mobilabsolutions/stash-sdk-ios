//
//  ErrorPresentationTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 21.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class ErrorPresentationTests: BaseUITest {
    func testPresentsErrorsWhenSkippingFields() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Country"].tap()
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
        collectionViewsQuery.textFields["Country"].tap()
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
}
