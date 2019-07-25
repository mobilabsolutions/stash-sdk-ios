/*
 IMPORTANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreeDropIn_TokenizationKey_CardForm_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_dismissesWhenCancelled() {
        self.waitForElementToBeHittable(self.app.buttons["Cancel"])
        self.app.buttons["Cancel"].forceTapElement()
        XCTAssertTrue(self.app.buttons["Cancelled🎲"].exists)
    }

    func testDropIn_displaysPaymentOptions_applePay_card_payPal() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        sleep(1)
        XCTAssertTrue(self.app.staticTexts["Credit or Debit Card"].exists)
        XCTAssertTrue(self.app.staticTexts["PayPal"].exists)
        XCTAssertTrue(self.app.staticTexts["Apple Pay"].exists)
    }

    func testDropIn_cardInput_receivesNonce() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["ending in 11"])

        XCTAssertTrue(self.app.staticTexts["ending in 11"].exists)
    }

    func testDropIn_cardInput_showsInvalidState_withInvalidCardNumber() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4141414141414141")

        self.waitForElementToAppear(elementsQuery.staticTexts["You must provide a valid Card Number."])
    }

    func testDropIn_cardInput_hidesInvalidCardNumberState_withDeletion() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4141414141414141")

        self.waitForElementToAppear(elementsQuery.staticTexts["You must provide a valid Card Number."])

        cardNumberTextField.typeText("\u{8}")

        XCTAssertFalse(elementsQuery.textFields["Invalid: Card Number"].exists)
    }
}

class BraintreeDropIn_securityCodeValidation_CardForm_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        // NOTE: This sandbox client token has CVV validation enabled.
        self.app.launchArguments.append("-Authorization:eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI2ZGE5Y2VhMzVkNGNlMjkxNGI3YzBiOGRiN2M5OWU4MjVmYTQ5ZTY5OTNiYWM4YmE3MTQwYjdiZjI0ODc4NGQ0fGNyZWF0ZWRfYXQ9MjAxOC0wMy0xMlQyMTo0MzoxMS4wOTI1MzAxNDcrMDAwMCZjdXN0b21lcl9pZD01ODA3NDE3NzEmbWVyY2hhbnRfaWQ9aGg0Y3BjMzl6cTRyZ2pjZyZwdWJsaWNfa2V5PXEzanRzcTNkM3Aycmg1dnQiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvaGg0Y3BjMzl6cTRyZ2pjZy9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJncmFwaFFMVXJsIjoiaHR0cHM6Ly9wYXltZW50cy5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tL2dyYXBocWwiLCJjaGFsbGVuZ2VzIjpbImN2diJdLCJlbnZpcm9ubWVudCI6InNhbmRib3giLCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvaGg0Y3BjMzl6cTRyZ2pjZy9jbGllbnRfYXBpIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhdXRoVXJsIjoiaHR0cHM6Ly9hdXRoLnZlbm1vLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhbmFseXRpY3MiOnsidXJsIjoiaHR0cHM6Ly9jbGllbnQtYW5hbHl0aWNzLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20vaGg0Y3BjMzl6cTRyZ2pjZyJ9LCJ0aHJlZURTZWN1cmVFbmFibGVkIjp0cnVlLCJwYXlwYWxFbmFibGVkIjp0cnVlLCJwYXlwYWwiOnsiZGlzcGxheU5hbWUiOiJidCIsImNsaWVudElkIjoiQVZRSmY5YS1iNmptWUZnaW9OcEkyaTU3cnNRa0hqUlpadjRkOURaTFRVMG5CU3Vma2h3QUNBWnhqMGxkdTg1amFzTTAyakZSUEthVElOQ04iLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjpmYWxzZSwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwidW52ZXR0ZWRNZXJjaGFudCI6ZmFsc2UsImJyYWludHJlZUNsaWVudElkIjoibWFzdGVyY2xpZW50MyIsImJpbGxpbmdBZ3JlZW1lbnRzRW5hYmxlZCI6dHJ1ZSwibWVyY2hhbnRBY2NvdW50SWQiOiJjNXljdzJzdnlrbnp3anR6IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sIm1lcmNoYW50SWQiOiJoaDRjcGMzOXpxNHJnamNnIiwidmVubW8iOiJvZmYiLCJicmFpbnRyZWVfYXBpIjp7InVybCI6Imh0dHBzOi8vcGF5bWVudHMuc2FuZGJveC5icmFpbnRyZWUtYXBpLmNvbSIsImFjY2Vzc190b2tlbiI6InNhbmRib3hfNmRkdG13X3B6YjZ3cF93ZHdoY3lfOWhnNm5iX2N5NiJ9fQ==")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Change Payment Method"])
        self.app.buttons["Change Payment Method"].tap()
    }

    func testDropIn_invalidSecurityCode_presentsAlert() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4000000000000002")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("200")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToBeHittable(self.app.alerts.buttons["OK"])
        XCTAssertTrue(self.app.alerts.staticTexts["Please review your information and try again."].exists)
        self.app.alerts.buttons["OK"].tap()

        // Assert: can edit after dismissing alert
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("\u{8}1")
    }
}

class BraintreeDropIn_CardDisabled_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-CardDisabled")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_cardDisabledOption_disablesCreditCard() {
        XCTAssertTrue(self.app.staticTexts["PayPal"].exists)
        XCTAssertFalse(self.app.staticTexts["Credit or Debit Card"].exists)
    }
}

class BraintreeDropIn_CardForm_RequestOptions_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        self.app.launchArguments.append("-MaskSecurityCode")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_maskSecurityCodeOption_enablesSecureTextEntry() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        let securityCodeField = elementsQuery.secureTextFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)

        XCTAssertFalse(elementsQuery.textFields["CVV"].exists)
    }
}

class BraintreeDropIn_CardholderNameNotAvailable_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_cardholderNameNotAvailable_fieldDoesntExist() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])

        let cardholderNameField = elementsQuery.textFields["Cardholder Name"]
        XCTAssertFalse(cardholderNameField.exists)
    }
}

class BraintreeDropIn_CardholderNameAvailable_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        self.app.launchArguments.append("-CardholderNameAccepted")
        self.app.launch()
        sleep(1)

        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()

        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()
    }

    func testDropIn_cardholderNameAvailable_fieldExists() {
        let elementsQuery = self.app.scrollViews.otherElements

        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        let cardholderNameField = elementsQuery.textFields["Cardholder Name"]
        self.waitForElementToAppear(cardholderNameField)
        XCTAssertTrue(cardholderNameField.exists)
    }

    func testDropIn_cardholderNameAvailable_canAddCardWithoutName() {
        let elementsQuery = self.app.scrollViews.otherElements

        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        let cardholderNameTextField = elementsQuery.textFields["Cardholder Name"]
        cardholderNameTextField.typeText("\n")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["ending in 11"])

        XCTAssertTrue(self.app.staticTexts["ending in 11"].exists)
    }
}

class BraintreeDropIn_CardholderNameRequired_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        self.app.launchArguments.append("-CardholderNameRequired")
        self.app.launch()
        sleep(1)

        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()

        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()
    }

    func testDropIn_cardholderNameRequired_fieldExists() {
        let elementsQuery = self.app.scrollViews.otherElements

        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        let cardholderNameField = elementsQuery.textFields["Cardholder Name"]
        self.waitForElementToAppear(cardholderNameField)

        XCTAssertTrue(cardholderNameField.exists)
    }

    func testDropIn_cardholderNameRequired_cannotAddCardWithoutName() {
        let elementsQuery = self.app.scrollViews.otherElements

        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        let cardholderNameTextField = elementsQuery.textFields["Cardholder Name"]
        cardholderNameTextField.typeText("\n")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        XCTAssertFalse(self.app.buttons["Add Card"].isEnabled)
    }

    func testDropIn_cardholderNameRequired_canAddCardWithName() {
        let elementsQuery = self.app.scrollViews.otherElements

        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        let cardholderNameField = elementsQuery.textFields["Cardholder Name"]
        self.waitForElementToBeHittable(cardholderNameField)
        cardholderNameField.typeText("First Last\n")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["ending in 11"])

        XCTAssertTrue(self.app.staticTexts["ending in 11"].exists)
    }
}

class BraintreeDropIn_ClientToken_CardForm_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-ClientToken")
        self.app.launchArguments.append("-ThreeDSecureDefault")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_cardInput_receivesNonce() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")
        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = self.app.scrollViews.otherElements.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = self.app.scrollViews.otherElements.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["ending in 11"])

        XCTAssertTrue(self.app.staticTexts["ending in 11"].exists)
    }

    func testDropIn_nonUnionPayCardNumber_showsNextButton() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        XCTAssertTrue(self.app.buttons["Next"].exists)
    }

    func testDropIn_hidesValidateButtonAfterCardNumberEntered() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        XCTAssertFalse(self.app.buttons["Next"].exists)
    }

    func pendDropIn_showsSpinnerDuringUnionPayCapabilitiesFetch() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("6212345678901232")

        self.waitForElementToBeHittable(self.app.buttons["Next"])
        self.app.buttons["Next"].forceTapElement()
        XCTAssertTrue(self.app.activityIndicators.count == 1 && self.app.activityIndicators["In progress"].exists)
    }

    func pendDropIn_unionPayCardNumber_receivesNonce() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("6212345678901232")

        self.waitForElementToBeHittable(self.app.buttons["Next"])
        self.app.buttons["Next"].forceTapElement()

        let expiryTextField = elementsQuery.textFields["MM/YYYY"]
        self.waitForElementToBeHittable(expiryTextField)

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        elementsQuery.textFields["Security Code"].typeText("565")
        self.app.typeText("65")

        self.app.staticTexts["Mobile Number"].forceTapElement()
        self.app.typeText("1235566543")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToBeHittable(self.app.alerts.buttons["OK"])
        self.app.alerts.buttons["OK"].tap()

        self.waitForElementToBeHittable(self.app.textFields["SMS Code"])
        self.app.textFields["SMS Code"].forceTapElement()
        self.app.typeText("12345")

        self.waitForElementToBeHittable(self.app.buttons["Confirm"])
        self.app.buttons["Confirm"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["ending in 32"])

        XCTAssertTrue(self.app.staticTexts["ending in 32"].exists)
    }

    func testDropIn_cardInput_doesNotShowCardIOButton_inSimulator() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")
        XCTAssertFalse(self.app.staticTexts["Scan with card.io"].exists)
    }
}

class BraintreeDropIn_PayPal_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_paypal_showsPayPal() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        XCTAssertTrue(self.app.staticTexts["PayPal"].exists)
    }

    func testDropIn_paypal_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        self.waitForElementToBeHittable(self.app.staticTexts["PayPal"])
        self.app.staticTexts["PayPal"].tap()
        sleep(3)

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToBeHittable(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["bt_buyer_us@paypal.com"])

        XCTAssertTrue(self.app.staticTexts["bt_buyer_us@paypal.com"].exists)
    }

    func testDropIn_paypal_cancelPopupShowsSelectPaymentMethodView() {
        if #available(iOS 11.0, *) {
            return
        }

        self.waitForElementToBeHittable(self.app.staticTexts["PayPal"])
        self.app.staticTexts["PayPal"].tap()
        sleep(3)

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToBeHittable(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["Select Payment Method"])

        XCTAssertTrue(self.app.staticTexts["Select Payment Method"].exists)
    }
}

class BraintreeDropIn_PayPal_OneTime_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-PayPalOneTime")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_paypal_showAmount_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        self.waitForElementToBeHittable(self.app.staticTexts["PayPal"])
        self.app.staticTexts["PayPal"].tap()
        sleep(3)

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.staticTexts["4.77"])

        self.waitForElementToBeHittable(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["bt_buyer_us@paypal.com"])

        XCTAssertTrue(self.app.staticTexts["bt_buyer_us@paypal.com"].exists)
    }
}

class BraintreeDropIn_PayPal_Disabled_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-DisablePayPal")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_paypal_doesNotShowPayPal_whenDisabled() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        XCTAssertFalse(self.app.staticTexts["PayPal"].exists)
    }
}

class BraintreeDropIn_ThreeDSecure_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-ClientToken")
        self.app.launchArguments.append("-ThreeDSecureRequired")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_threeDSecure_showsThreeDSecureWebview_andTransacts() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["Added Protection"])

        let textField = self.app.secureTextFields.element(boundBy: 0)
        self.waitForElementToBeHittable(textField)
        textField.forceTapElement()
        sleep(2)
        textField.typeText("1234")

        self.app.buttons["Submit"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["ending in 11"])

        XCTAssertTrue(self.app.staticTexts["ending in 11"].exists)

        self.waitForElementToBeHittable(self.app.buttons["Complete Purchase"])
        self.app.buttons["Complete Purchase"].forceTapElement()

        let existsPredicate = NSPredicate(format: "label LIKE 'created*'")

        self.waitForElementToAppear(self.app.buttons.containing(existsPredicate).element(boundBy: 0))
    }

    func testDropIn_threeDSecure_returnsToPaymentSelectionView_whenCancelled() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4111111111111111")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["11"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["Added Protection"])

        self.app.buttons["Done"].forceTapElement()
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.waitForElementToAppear(self.app.staticTexts["Select Payment Method"])

        self.waitForElementToBeHittable(self.app.buttons["Cancel"])
        self.app.buttons["Cancel"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["Cancelled🎲"])
        XCTAssertTrue(self.app.buttons["Cancelled🎲"].exists)
    }

    func testDropIn_threeDSecure_tokenizationError_showsAlert() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.app.staticTexts["Credit or Debit Card"].tap()

        let elementsQuery = self.app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        self.waitForElementToBeHittable(cardNumberTextField)
        cardNumberTextField.typeText("4687380000000008")

        self.waitForElementToBeHittable(self.app.staticTexts[Date.getNextYear()])
        self.app.staticTexts["01"].forceTapElement()
        self.app.staticTexts[Date.getNextYear()].forceTapElement()

        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("200")

        let postalCodeField = elementsQuery.textFields["12345"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")

        self.app.buttons["Add Card"].forceTapElement()

        self.waitForElementToBeHittable(self.app.alerts.buttons["OK"])
        XCTAssertTrue(self.app.alerts.staticTexts["Please review your information and try again."].exists)
        self.app.alerts.buttons["OK"].tap()

        // Assert: can edit after dismissing alert
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("\u{8}1")
    }
}

class BraintreeDropIn_Venmo_Disabled_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ForceVenmo")
        self.app.launchArguments.append("-DisableVenmo")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_venmo_doesNotShow_whenDisabled() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        XCTAssertFalse(self.app.staticTexts["Venmo"].exists)
    }
}

class BraintreeDropIn_Venmo_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-ForceVenmo")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_venmo_doesShow() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        XCTAssertTrue(self.app.staticTexts["Venmo"].exists)
    }
}

class BraintreeDropIn_Error_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-BadUrlScheme")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Add Payment Method"])
        self.app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_paypal_receivesError_whenUrlSchemeIsIncorrect() {
        self.waitForElementToBeHittable(self.app.staticTexts["PayPal"])
        self.app.staticTexts["PayPal"].tap()
        sleep(3)

        let existsPredicate = NSPredicate(format: "label LIKE '*Application does not support One Touch callback*'")

        self.waitForElementToAppear(self.app.buttons.containing(existsPredicate).element(boundBy: 0))
    }
}
