//
//  AdyenUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class AdyenUITests: BaseUITest {
    #warning("Implement this test")
    func testCanCreateCreditCard() {
        let app = XCUIApplication()
        navigateToViewController(for: "Credit Card", with: "ADYEN", app: app)
    }
}
