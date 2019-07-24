//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class CardsTests: TestCase {
    override func setUp() {
        super.setUp()
        setCountry("NL", currency: "EUR")
        startCheckout()
    }

    func testSuccessfulPayment() {
        selectPaymentMethod("Credit Card")

        // Find the checkout button and ensure it's disabled.
        XCTAssertFalse(self.checkoutButton.isEnabled)

        // Enter the holder name.
        self.holderNameField.tap()
        self.holderNameField.typeText("Checkout Shopper")

        // The checkout button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(self.checkoutButton.isEnabled)

        // Enter the credit card number.
        self.numberField.tap()
        self.numberField.typeText("5555444433331111")

        // The checkout button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(self.checkoutButton.isEnabled)

        // Enter the expiration date.
        self.expiryDateField.tap()
        self.expiryDateField.typeText("1020")

        // The checkout button should still be disabled while waiting for the user to complete input.
        XCTAssertFalse(self.checkoutButton.isEnabled)

        // Enter the CVC.
        self.cvcField.tap()
        self.cvcField.typeText("737")

        // After completing the input, the checkout button should be enabled.
        XCTAssertTrue(self.checkoutButton.isEnabled)

        // Tap the checkout button.
        self.checkoutButton.tap()

        dismissSuccessAlert()
    }

    func testSuccessfulOneClickPayment() {
        selectPaymentMethod()

        app.tables.last.cells.first.tap()

        // Enter a valid CVC and submit.
        self.oneClickVerificationAlert.textFields.first.typeText("737")
        self.oneClickVerificationAlert.buttons.last.tap()

        dismissSuccessAlert()
    }

    func testOneClickPaymentWithInvalidCVC() {
        selectPaymentMethod()

        app.tables.last.cells.first.tap()

        // Enter an invalid CVC and submit.
        self.oneClickVerificationAlert.textFields.first.typeText("123")
        self.oneClickVerificationAlert.buttons.last.tap()

        dismissFailureAlert()
    }

    // MARK: Elements

    private var contentView: XCUIElement {
        return app.scrollViews.first
    }

    private var holderNameField: XCUIElement {
        return self.contentView.textFields["holder-name-field"]
    }

    private var numberField: XCUIElement {
        return self.contentView.textFields["number-field"]
    }

    private var expiryDateField: XCUIElement {
        return self.contentView.textFields["expiry-date-field"]
    }

    private var cvcField: XCUIElement {
        return self.contentView.textFields["cvc-field"]
    }

    private var checkoutButton: XCUIElement {
        return self.contentView.buttons["pay-button"]
    }

    private var oneClickVerificationAlert: XCUIElement {
        return app.alerts["Verify your card"]
    }
}
