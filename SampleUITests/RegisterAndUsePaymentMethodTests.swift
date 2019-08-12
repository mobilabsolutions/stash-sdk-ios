//
//  RegisterAndUsePaymentMethodTests.swift
//  SampleUITests
//
//  Created by Robert on 16.07.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import XCTest

class RegisterAndUsePaymentMethodTests: BaseUITest {
    private let backend = TestMerchantBackend()

    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    func testCanRegisterAndUsePayPal() {
        let app = XCUIApplication()
        registerPayPal(in: app)
        verifyCanPayWithLatestCreatedAlias(type: "PAY_PAL", in: app)
    }

    func testCanRegisterAndUseAdyenCreditCard() {
        let app = XCUIApplication()
        registerCreditCard(psp: "ADYEN", in: app)
        verifyCanPayWithLatestCreatedAlias(type: "CC", in: app)
    }

    func testCanRegisterAndUseBSPayoneCreditCard() {
        let app = XCUIApplication()
        registerCreditCard(psp: "BS_PAYONE", in: app)
        verifyCanPayWithLatestCreatedAlias(type: "CC", in: app)
    }

    func testCanRegisterAndUseAdyenSEPA() {
        let app = XCUIApplication()
        registerSEPA(psp: "ADYEN", in: app)
        verifyCanPayWithLatestCreatedAlias(type: "SEPA", in: app)
    }

    func testCanRegisterAndUseBSPayoneSEPA() {
        let app = XCUIApplication()
        registerSEPA(psp: "BS_PAYONE", in: app)
        verifyCanPayWithLatestCreatedAlias(type: "SEPA", in: app)
    }

    private func verifyCanPayWithLatestCreatedAlias(type: String, in app: XCUIApplication) {
        app.tabBars.buttons["Featured"].tap()
        let aliasLabel = app.staticTexts["Alias Label"].firstMatch

        XCTAssert(aliasLabel.exists)

        guard let alias = aliasLabel.value as? String
        else { XCTFail("Should be able to retrieve string alias from the alias label"); return }

        let canRegisterExpectation = expectation(description: "Can create a payment method alias entry in the merchant backend")
        let canPayExpectation = expectation(description: "Can pay with created PayPal payment method")

        backend.createPaymentMethod(alias: alias, paymentMethodType: type) { result in
            switch result {
            case let .success(method):
                self.payUsingPaymentMethod(id: method.paymentMethodId, amount: 300, currency: "EUR", expectation: canPayExpectation)
            case let .failure(error):
                XCTFail("Could not register a payment method with the merchant backend: \(error)")
            }

            canRegisterExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    private func payUsingPaymentMethod(id: String, amount: Int, currency: String, expectation: XCTestExpectation) {
        let paymentRequest = PaymentRequest(amount: amount, currency: currency, paymentMethodId: id, reason: "Test payment")
        backend.authorizePayment(payment: paymentRequest) { result in
            switch result {
            case let .success(authorization):
                XCTAssertEqual(authorization.currency, currency, "The returned currency should equal the authorized currency")
                XCTAssertEqual(authorization.amount, amount, "The returned amount should equal the authorized amount")
                XCTAssertNotNil(authorization.transactionId, "There should be an associated transaction id for a payment authorization")
            case let .failure(error):
                XCTFail("An error occurred while authorizing payment: \(error)")
            }

            expectation.fulfill()
        }
    }

    private func registerCreditCard(psp: String, in app: XCUIApplication) {
        let app = XCUIApplication()
        showSpecificUI(for: "CC", with: psp, in: app)

        let firstName = "Max"
        let lastName = "Mustermann"

        let cardNumber: String
        let cvv: String
        let month: String
        let year: String
        let countryIndex: Int?

        switch psp {
        case "ADYEN":
            cardNumber = "3600 6666 3333 44"
            cvv = "737"
            month = "10"
            year = "2020"
            countryIndex = nil
        default:
            cardNumber = "4111 1111 1111 1111"
            cvv = "737"
            month = "10"
            year = "2020"
            countryIndex = 4
        }

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText(firstName)

        collectionViewsQuery.textFields["1234"].tap()
        collectionViewsQuery.textFields["1234"].typeText(cardNumber)

        collectionViewsQuery.textFields["MM/YY"].tap()
        app.pickers.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: month)
        app.pickers.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: year)

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText(lastName)

        collectionViewsQuery.textFields["CVV/CVC"].tap()
        collectionViewsQuery.textFields["CVV/CVC"].typeText(cvv)

        if let countryIndex = countryIndex {
            collectionViewsQuery.buttons["Country"].tap()
            app.collectionViews.cells.element(boundBy: countryIndex).tap()
        }

        app.collectionViews.firstMatch.tap()
        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)

        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid credit card")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    private func registerSEPA(psp: String, in app: XCUIApplication) {
        showSpecificUI(for: "SEPA", with: psp, in: app)

        let countryIndex = psp == "BS_PAYONE" ? 5 : nil

        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery.textFields["First Name"].tap()
        collectionViewsQuery.textFields["First Name"].typeText("Bertram")

        collectionViewsQuery.textFields["Last Name"].tap()
        collectionViewsQuery.textFields["Last Name"].typeText("Schneider")

        collectionViewsQuery.textFields["XX123"].tap()
        collectionViewsQuery.textFields["XX123"].typeText("DE92123456789876543210")

        if let countryIndex = countryIndex {
            collectionViewsQuery.buttons["Country"].tap()
            app.collectionViews.cells.element(boundBy: countryIndex).tap()
        } else {
            // Tap continue button on IBAN field
            app.keyboards.buttons.allElementsBoundByIndex.last?.tap()
        }

        app.buttons["SAVE"].tap()

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }

    private func registerPayPal(in app: XCUIApplication) {
        showSpecificUI(for: "PayPal", in: app)

        let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let alert = springBoard.alerts.firstMatch
        XCTAssert(alert.waitForExistence(timeout: 10))
        alert.buttons["Continue"].tap()

        let webViewButton = app.webViews
            .staticTexts["Proceed with Sandbox Purchase"].firstMatch
        XCTAssert(webViewButton.waitForExistence(timeout: 15))
        webViewButton.tap()

        waitForElementToAppear(element: app.alerts.firstMatch)
        XCTAssertTrue(app.alerts.firstMatch.staticTexts.firstMatch.label.contains("Success"),
                      "Expected \"Success\" text in the app alert when adding a valid SEPA method")
        app.alerts.firstMatch.buttons.firstMatch.tap()
    }
}
