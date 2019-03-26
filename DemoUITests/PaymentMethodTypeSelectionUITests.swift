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

        XCTAssertEqual(app.cells.count, supportedMethodTypes.count)

        for cell in app.cells.allElementsBoundByIndex {
            XCTAssertTrue(cell.staticTexts.allElementsBoundByIndex
                .contains {
                    supportedMethodTypes.map({ $0.1 }).contains($0.label)
            })
        }
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
//        XCTAssertTrue(app.activityIndicators.element.exists)
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
