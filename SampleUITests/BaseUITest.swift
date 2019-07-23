//
//  BaseUITest.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import XCTest

class BaseUITest: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func navigateToViewController(for paymentMethodTypeTitle: String, with psp: String = "BS_PAYONE", app: XCUIApplication) {
        app.tabBars.buttons["Bookmarks"].tap()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: psp)
        app.buttons["Trigger Register UI"].tap()

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts[paymentMethodTypeTitle].tap()
    }

    func showSpecificUI(for paymentMethodType: String, in app: XCUIApplication, psp: String = "BS_PAYONE") {
        app.tabBars.buttons["Bookmarks"].tap()
        app.segmentedControls.buttons[paymentMethodType].tap()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: psp)
        app.buttons["Show Specific UI"].tap()
    }

    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5, file: String = #file, line: UInt = #line) {
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
