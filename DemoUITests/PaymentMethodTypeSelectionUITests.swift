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

        let supportedMethodTypes: [(PaymentMethodType, String)] = [(.creditCard, "Card"), (.sepa, "SEPA"), (.payPal, "PayPal")]

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

        waitForElementToAppear(element: app.alerts.firstMatch)

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

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"))
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    private func navigateToViewController(for paymentMethodTypeTitle: String, app: XCUIApplication) {
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts[paymentMethodTypeTitle].tap()
    }

    #warning("Uncomment when PayPal implementation is done")
//    func testLoadingViewIsShownForPayPalRegistration() {
//        let app = XCUIApplication()
//        app.tabBars.buttons["Bookmarks"].tap()
//        app.buttons["Trigger Register UI"].tap()
//
//        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
//        payPalCell.tap()
//
//        XCTAssertTrue(app.activityIndicators.element.exists)
//    }
//
//    func testPayPalViewIsShown() {
//        let app = XCUIApplication()
//        app.tabBars.buttons["Bookmarks"].tap()
//        app.buttons["Trigger Register UI"].tap()
//
//        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
//        payPalCell.tap()
//
//        let payPalView = app.otherElements["PayPalView"]
//        self.waitForElementToAppear(element: payPalView, timeout: 10)
//    }

    private func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")

        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: timeout) { (error) -> Void in
            if error != nil {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
}
