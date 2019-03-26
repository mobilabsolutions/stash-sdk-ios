/*
 IMPORTANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreeDropIn_EditMode_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-EditModeCustomer")
        self.app.launchArguments.append("-ClientToken")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Change Payment Method"])
        self.app.buttons["Change Payment Method"].tap()
    }

    func testDropIn_canDisplay_editScreen() {
        self.waitForElementToBeHittable(self.app.buttons["Edit"])
        self.app.buttons["Edit"].forceTapElement()

        self.waitForElementToAppear(self.app.staticTexts["Edit Payment Methods"])
    }

    func testDropIn_editScreen_returnsToPaymentSelection() {
        self.waitForElementToBeHittable(self.app.buttons["Edit"])
        self.app.buttons["Edit"].forceTapElement()

        self.waitForElementToBeHittable(self.app.buttons["Done"])
        self.app.buttons["Done"].forceTapElement()

        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])
        self.waitForElementToAppear(self.app.staticTexts["Select Payment Method"])
    }
}

class BraintreeDropIn_EditMode_Disabled_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments.append("-EnvironmentSandbox")
        self.app.launchArguments.append("-EditModeCustomer")
        self.app.launchArguments.append("-DisableEditMode")
        self.app.launchArguments.append("-ClientToken")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(self.app.buttons["Change Payment Method"])
        self.app.buttons["Change Payment Method"].tap()
    }

    func testDropIn_canDisplay_editScreen() {
        self.waitForElementToBeHittable(self.app.staticTexts["Credit or Debit Card"])

        XCTAssertFalse(self.app.buttons["Edit"].exists)
    }
}
