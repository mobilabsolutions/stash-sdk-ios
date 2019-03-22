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
}
