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

        let supportedMethodTypes: [(PaymentMethodType, String)] = [(.creditCard, "Credit Card"), (.sepa, "SEPA"), (.payPal, "PayPal")]

        XCTAssertEqual(app.cells.count, supportedMethodTypes.count,
                       "There should be \(supportedMethodTypes.count) payment methods on selection screen but only saw \(app.cells.count)")

        for methodType in supportedMethodTypes {
            XCTAssertTrue(app.cells.staticTexts.allElementsBoundByIndex.map({ $0.label }).contains(methodType.1),
                          "Methods should contain \(methodType.1)")
        }
    }

    func testCanAddCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

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

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testRejectsInvalidCardNumber() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

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

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "not valid")).element.exists,
                      "Expected failure label to exist when adding a card with invalid number")
    }

    func testRejectsSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Name"].tap()
        collectionViewsQuery.textFields["Name"].typeText("Max Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE123456789")

        collectionViewsQuery.textFields["XXX"].tap()
        collectionViewsQuery.textFields["XXX"].typeText("COLSDE33XXX")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "not valid")).element.exists,
                      "Expected failure label to exist when adding a SEPA method with invalid number")
    }

    func testCanAddSepaMethod() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

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
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    func testReturnKeyNavigationIsEnabled() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Name"].tap()

        app.keys["M"].tap()

        // Tap on the "continue" keyboard button
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.keys["A"].tap()

        // Tap on the "continue" keyboard button
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.keys["B"].tap()

        // Tap on the "continue" keyboard button
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()

        guard let nameFieldText = collectionViewsQuery.textFields["Name"].value as? String
        else { XCTFail("Could not retrieve string value from name text field"); return }

        guard let ibanText = collectionViewsQuery.textFields["XX123"].value as? String
        else { XCTFail("Could not retrieve string value from IBAN text field"); return }

        guard let bicText = collectionViewsQuery.textFields["XXX"].value as? String
        else { XCTFail("Could not retrieve string value from BIC text field"); return }

        // This text should now be in the IBAN text field
        XCTAssertEqual(bicText, "B")
        // This text should now be in the IBAN text field
        XCTAssertEqual(ibanText, "A")
        // There should not have been any effect on the name field
        XCTAssertEqual(nameFieldText, "M")

        XCTAssertEqual(app.keyboards.count, 0, "After tapping the continue button on the last text field, the keyboard should disappear")
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
//        XCTAssertTrue(app.activityIndicators.element.exists, "Expected activity indicator to exist for loading view for PayPal registration")
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
