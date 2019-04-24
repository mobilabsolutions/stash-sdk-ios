//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class SEPADirectDebitTests: TestCase {
    override func setUp() {
        super.setUp()

        setCountry("NL", currency: "EUR")
        startCheckout()
        selectPaymentMethod("SEPA Direct Debit")
    }

    func testSuccessfulPayment() {
        // Find the pay button and ensure it's disabled.
        XCTAssertFalse(self.payButton.isEnabled)

        // Enter the IBAN.
        self.ibanField.typeText("nl13test0123456789")

        // The pay button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(self.payButton.isEnabled)

        // Enter the name.
        self.nameField.tap()
        self.nameField.typeText("A. Klaassen")

        // After completing the input, the pay button should be enabled.
        XCTAssertTrue(self.payButton.isEnabled)

        // Tap the pay button.
        self.payButton.tap()

        dismissSuccessAlert()
    }

    // MARK: Elements

    private var contentView: XCUIElement {
        return app.scrollViews.first
    }

    private var ibanField: XCUIElement {
        return self.contentView.textFields["iban-field"]
    }

    private var nameField: XCUIElement {
        return self.contentView.textFields["name-field"]
    }

    private var payButton: XCUIElement {
        return self.contentView.buttons["pay-button"]
    }
}
