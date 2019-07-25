//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class KlarnaTests: TestCase {
    func testKlarnaFlowForNetherlands() {
        setCountry("NL", currency: "EUR")
        startCheckout()

        selectPaymentMethod("Achteraf betalen. Klarna.")

        // Personal details
        self.firstNameField.typeText("Testperson-nl")
        self.lastNameField.tapAndType("Approved")
        self.setDate(day: "10", month: "July", year: "1970")
        self.telephoneNumberField.tapAndType("0612345678")
        self.emailField.tapAndType("youremail@email.com")

        // Address
        self.streetField.tapAndType("Neherkade")
        self.houseNumberField.tapAndType("1")
        self.cityField.tapAndType("Gravenhage")
        self.postalCodeField.tapAndType("2521VA")

        // Pay
        self.payButton.tap()
        dismissSuccessAlert()
    }

    func testKlarnaFlowForNorway() {
        setCountry("NO", currency: "NOK")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")

        // Personal details
        self.firstNameField.typeText("Testperson-no")
        self.lastNameField.tapAndType("Approved")
        self.telephoneNumberField.tapAndType("40 123 456")
        self.emailField.tapAndType("youremail@email.com")
        self.ssnField.tapAndType("01087000571")

        // Address
        self.streetField.tapAndType("Sæffleberggate")
        self.houseNumberField.tapAndType("56")
        self.cityField.tapAndType("Oslo")
        self.postalCodeField.tapAndType("0563")

        // Pay
        self.payButton.tap()
        dismissSuccessAlert()
    }

    func testKlarnaFlowForSweden() {
        setCountry("SE", currency: "SEK")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")

        // Personal details
        self.ssnField.tapAndType("4103219202")

        waitForElementToAppear(self.telephoneNumberField)

        self.telephoneNumberField.tapAndType("0765260000")
        self.emailField.tapAndType("youremail@email.com")

        // Pay
        self.payButton.tap()
        dismissSuccessAlert()
    }

    func testKlarnaFlowForFinland() {
        setCountry("FI", currency: "EUR")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")

        // Personal details
        self.firstNameField.typeText("Testperson-fi")
        self.lastNameField.tapAndType("Approved")
        self.telephoneNumberField.tapAndType("0401234567")
        self.emailField.tapAndType("youremail@email.com")
        self.ssnField.tapAndType("190122-829F")

        // Address
        self.streetField.tapAndType("Kiväärikatu")
        self.houseNumberField.tapAndType("10")
        self.cityField.tapAndType("Pori")
        self.postalCodeField.tapAndType("28100")

        // Pay
        self.payButton.tap()
        dismissSuccessAlert()
    }

    func testKlarnaFlowForGermany() {
        setCountry("DE", currency: "EUR")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")

        // Personal details
        self.firstNameField.typeText("Testperson-de")
        self.lastNameField.tapAndType("Approved")
        self.telephoneNumberField.tapAndType("01522113356")
        self.emailField.tapAndType("youremail@email.com")
        self.setDate(day: "7", month: "July", year: "1960")

        // Address
        self.streetField.tapAndType("Hellersbergstraße")
        self.houseNumberField.tapAndType("14")
        self.cityField.tapAndType("Neuss")
        self.postalCodeField.tapAndType("41460")

        self.consentButton.tap()

        // Pay
        self.payButton.tap()
        dismissSuccessAlert()
    }

    // MARK: Helpers

    private func setDate(day: String, month: String, year: String) {
        self.dateField.tap()

        app.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: month)
        app.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: day)
        app.pickerWheels.allElementsBoundByIndex[2].adjust(toPickerWheelValue: year)
    }

    // MARK: Elements

    private var contentView: XCUIElement {
        return app.scrollViews.first
    }

    private var firstNameField: XCUIElement {
        return self.contentView.textFields["first-name-field"]
    }

    private var lastNameField: XCUIElement {
        return self.contentView.textFields["last-name-field"]
    }

    private var genderField: XCUIElement {
        return self.contentView.buttons["gender-field"]
    }

    private var dateField: XCUIElement {
        return self.contentView.buttons["date-field"]
    }

    private var telephoneNumberField: XCUIElement {
        return self.contentView.textFields["telephone-number-field"]
    }

    private var emailField: XCUIElement {
        return self.contentView.textFields["email-field"]
    }

    private var ssnField: XCUIElement {
        return self.contentView.textFields["social-security-number-field"]
    }

    private var streetField: XCUIElement {
        return self.contentView.textFields["street-field"]
    }

    private var houseNumberField: XCUIElement {
        return self.contentView.textFields["house-number-field"]
    }

    private var cityField: XCUIElement {
        return self.contentView.textFields["city-field"]
    }

    private var postalCodeField: XCUIElement {
        return self.contentView.textFields["postal-code-field"]
    }

    private var payButton: XCUIElement {
        return self.contentView.buttons["pay-button"]
    }

    private var consentButton: XCUIElement {
        return self.contentView.otherElements["consent-button"].switches.first
    }
}
