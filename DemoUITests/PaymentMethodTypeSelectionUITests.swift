//
//  PaymentMethodTypeSelectionUITests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class PaymentMethodTypeSelectionUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testOpensPaymentTypeSelectionScreen() {
        let app = XCUIApplication()
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let supportedMethodTypes: [(PaymentMethodType, String)] = [(.creditCard, "Card"), (.sepa, "Sepa")]

        XCTAssertEqual(app.cells.count, supportedMethodTypes.count)
        for methodType in supportedMethodTypes {
            XCTAssertTrue(app.cells.staticTexts.allElementsBoundByIndex.map({ $0.label }).contains(methodType.1))
        }
    }

    func testCanAddCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Name"].tap()
        collectionViewsQuery.textFields["Name"].typeText("Max Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("4111 1111 1111 1111")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["CVV"].tap()
        collectionViewsQuery.textFields["CVV"].typeText("123")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: app.alerts.firstMatch, handler: nil)
        self.waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"))
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testRejectsInvalidCardNumber() {
        let app = XCUIApplication()
        navigateToViewController(for: "Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Name"].tap()
        collectionViewsQuery.textFields["Name"].typeText("Max Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("123456789")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["CVV"].tap()
        collectionViewsQuery.textFields["CVV"].typeText("123")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "not valid")).element.exists)
    }

    func testRejectsSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "Sepa", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Name"].tap()
        collectionViewsQuery.textFields["Name"].typeText("Max Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE123456789")

        collectionViewsQuery.textFields["XXX"].tap()
        collectionViewsQuery.textFields["XXX"].typeText("COLSDE33XXX")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "not valid")).element.exists)
    }

    func testCanAddSepaMethod() {
        let app = XCUIApplication()
        navigateToViewController(for: "Sepa", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Name"].tap()
        collectionViewsQuery.textFields["Name"].typeText("Max Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE75512108001245126199")

        collectionViewsQuery.textFields["XXX"].tap()
        collectionViewsQuery.textFields["XXX"].typeText("COLSDE33XXX")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: app.alerts.firstMatch, handler: nil)
        self.waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"))
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    private func navigateToViewController(for paymentMethodTypeTitle: String, app: XCUIApplication) {
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts[paymentMethodTypeTitle].tap()
    }
}
