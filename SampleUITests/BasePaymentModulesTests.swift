//
//  BasePaymentModulesTests.swift
//  StashTests
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@testable import StashCore
import XCTest

class BasePaymentModulesTests: BaseUITest {
    func testOpensPaymentTypeSelectionScreen() {
        let app = XCUIApplication()
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let supportedMethodTypes: [(PaymentMethodType, String)] = [(.creditCard, "Credit Card"), (.sepa, "SEPA"), (.payPal, "PayPal")]

        XCTAssertEqual(app.cells.count, supportedMethodTypes.count,
                       "There should be \(supportedMethodTypes.count) payment methods on selection screen but only saw \(app.cells.count)")

        for methodType in supportedMethodTypes {
            XCTAssertTrue(app.cells.staticTexts.allElementsBoundByIndex.map { $0.label }.contains(methodType.1),
                          "Methods should contain \(methodType.1)")
        }
    }

    func testRejectsInvalidCardNumber() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("123456789")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("123")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).element.exists,
                      "Expected failure label to exist when adding a card with invalid number")
    }

    func testRejectsInvalidCVV() {
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
        collectionViewsQuery.textFields["CVV/CVC"].typeText("12345")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "valid CVV")).element.exists,
                      "Expected failure label to exist when adding a card with invalid CVV")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        self.deleteTextFieldText(textField: collectionViewsQuery.textFields["CVV/CVC"], app: app)

        collectionViewsQuery.textFields["CVV/CVC"].typeText("12")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "valid CVV")).element.exists,
                      "Expected failure label to exist when adding a card with invalid CVV")

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        self.deleteTextFieldText(textField: collectionViewsQuery.textFields["CVV/CVC"], app: app)

        collectionViewsQuery.textFields["CVV/CVC"].typeText("abc")

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "valid CVV")).element.exists,
                      "Expected failure label to exist when adding a card with invalid CVV")
    }

    func testRejectsSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE123456789")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.buttons["SAVE"].tap()

        XCTAssertTrue(collectionViewsQuery.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Please provide")).element.exists,
                      "Expected failure label to exist when adding a SEPA method with invalid number")
    }

    func testDoesNotEnableDoneButtonForInvalidCreditCardNumber() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        // Input invalid CC number
        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("41")

        collectionViewsQuery.textFields["MM/YY"].tap()

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("123")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        app.collectionViews.firstMatch.tap()
        XCTAssertFalse(app.buttons["SAVE"].isEnabled)

        // Update CC number to be valid
        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText("11 1111 1111 1111")

        app.collectionViews.firstMatch.tap()
        XCTAssertTrue(app.buttons["SAVE"].isEnabled)

        // Input invalid CVV
        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText("123456")

        app.collectionViews.firstMatch.tap()
        XCTAssertFalse(app.buttons["SAVE"].isEnabled)
    }

    func testDoesNotEnableDoneButtonForInvalidSEPA() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Max")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Mustermann")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE14123456")

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()

        app.collectionViews.firstMatch.tap()
        XCTAssertFalse(app.buttons["SAVE"].isEnabled)

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("780023456789")

        app.collectionViews.firstMatch.tap()
        XCTAssertTrue(app.buttons["SAVE"].isEnabled)
    }

    func testReturnKeyNavigationIsEnabled() {
        let app = XCUIApplication()
        navigateToViewController(for: "SEPA", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()

        app.keys["M"].tap()

        // Tap on the "continue" keyboard button
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.keys["A"].tap()

        // Tap on the "continue" keyboard button
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        app.keys["B"].tap()

        collectionViewsQuery.textFields["Country"].tap()
        app.collectionViews.cells.element(boundBy: 3).tap()

        // Tap on the "continue" keyboard button
        app.keyboards.buttons.allElementsBoundByIndex.last?.tap()

        guard let firstNameFieldText = collectionViewsQuery.textFields["First Name"].value as? String
        else { XCTFail("Could not retrieve string value from first name text field"); return }

        guard let lastNameFieldText = collectionViewsQuery.textFields["Last Name"].value as? String
        else { XCTFail("Could not retrieve string value from last name text field"); return }

        guard let ibanText = collectionViewsQuery.textFields["XX123"].value as? String
        else { XCTFail("Could not retrieve string value from IBAN text field"); return }

        guard let countryText = collectionViewsQuery.textFields["Country"].value as? String
        else { XCTFail("Could not retrieve string value from Country text field"); return }

        // This text should now be in the Country text field
        XCTAssertEqual(countryText, "Algeria")
        // This text should now be in the IBAN text field
        XCTAssertEqual(ibanText, "B")
        // This text should now be in the last name text field
        XCTAssertEqual(lastNameFieldText, "A")
        // There should not have been any effect on the first name field
        XCTAssertEqual(firstNameFieldText, "M")

        XCTAssertEqual(app.keyboards.count, 0, "After tapping the continue button on the last text field, the keyboard should disappear")
    }

    func deleteTextFieldText(textField: XCUIElement, app _: XCUIApplication) {
        guard let currentText = textField.value as? String
        else { return }

        let deleteText = currentText.map { _ in XCUIKeyboardKey.delete.rawValue }
        textField.typeText(deleteText.joined())
    }
}
