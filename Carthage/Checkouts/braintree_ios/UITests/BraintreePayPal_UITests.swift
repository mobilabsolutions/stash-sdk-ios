/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreePayPal_FuturePayment_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-Integration:BraintreeDemoPayPalForceFuturePaymentViewController")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["PayPal (future payment button)"])
        self.app.buttons["PayPal (future payment button)"].tap()
        sleep(2)
    }

    func testPayPal_futurePayment_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = self.app.webViews.element.otherElements
        let emailTextField = webviewElementsQuery.textFields["Email"]

        self.waitForElementToAppear(emailTextField)
        emailTextField.forceTapElement()
        emailTextField.typeText("test@paypal.com")

        let passwordTextField = webviewElementsQuery.secureTextFields["Password"]
        passwordTextField.forceTapElement()
        passwordTextField.typeText("1234")

        webviewElementsQuery.buttons["Log In"].forceTapElement()

        self.waitForElementToAppear(webviewElementsQuery.buttons["Agree"])

        webviewElementsQuery.buttons["Agree"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(self.app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testPayPal_futurePayment_cancelsSuccessfully() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = self.app.webViews.element.otherElements
        let emailTextField = webviewElementsQuery.textFields["Email"]

        self.waitForElementToAppear(emailTextField)

        // Close button has no accessibility helper
        // Purposely don't use the webviewElementsQuery variable
        // Reevaluate the elements query after the page load to get the close button
        self.app.webViews.buttons.element(boundBy: 0).forceTapElement()

        self.waitForElementToAppear(self.app.buttons["PayPal (future payment button)"])

        XCTAssertTrue(self.app.buttons["Canceled 🔰"].exists)
    }
}

class BraintreePayPal_SinglePayment_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-Integration:BraintreeDemoPayPalOneTimePaymentViewController")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["PayPal one-time payment"])
        self.app.buttons["PayPal one-time payment"].tap()
        sleep(2)
    }

    func testPayPal_singlePayment_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(self.app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testPayPal_singlePayment_cancelsSuccessfully() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["PayPal one-time payment"])

        XCTAssertTrue(self.app.buttons["Cancelled"].exists)
    }
}

class BraintreePayPal_BillingAgreement_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-TokenizationKey")
        self.app.launchArguments.append("-Integration:BraintreeDemoPayPalBillingAgreementViewController")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Billing Agreement with PayPal"])
        self.app.buttons["Billing Agreement with PayPal"].tap()
        sleep(2)
    }

    func testPayPal_billingAgreement_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(self.app.textViews["DismissalOfViewController Called"].exists)
        XCTAssertTrue(self.app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testPayPal_billingAgreement_cancelsSuccessfully() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = self.app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["Billing Agreement with PayPal"])

        XCTAssertTrue(self.app.textViews["DismissalOfViewController Called"].exists)
        XCTAssertTrue(self.app.buttons["Cancelled"].exists)
    }

    func testPayPal_billingAgreement_cancelsSuccessfully_whenTappingSFSafariViewControllerDoneButton() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        self.waitForElementToAppear(self.app.buttons["Done"])

        self.app.buttons["Done"].forceTapElement()

        self.waitForElementToAppear(self.app.buttons["Billing Agreement with PayPal"])

        XCTAssertTrue(self.app.textViews["DismissalOfViewController Called"].exists)
        XCTAssertTrue(self.app.buttons["Cancelled"].exists)
    }
}
