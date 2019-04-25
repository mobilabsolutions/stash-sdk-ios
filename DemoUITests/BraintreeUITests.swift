//
//  BraintreeUITests.swift
//  DemoUITests
//
//  Created by Robert on 05.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import XCTest

class BraintreeUITests: BaseUITest {

    func testLoadingViewIsShownForPayPalRegistration() {
        let app = XCUIApplication()
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
        payPalCell.tap()

        XCTAssertTrue(app.activityIndicators.element.exists, "Expected activity indicator to exist for loading view for PayPal registration")
    }

    func testPayPalViewIsShown() {
        
        let app = XCUIApplication()
        
        var hasDismissedSystemAlert = false
        let handler = addUIInterruptionMonitor(withDescription: "System Alert") {
            (alert) -> Bool in
            
            #warning("dismissing SystemAlert of type SFAuthenticationsession is unreliable")
            // Click the second button in dialog
            let button = alert.buttons.element(boundBy: 1)
            if button.exists {
                button.tap()
            }
            hasDismissedSystemAlert = true
            return true
        }
        
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()

        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
        payPalCell.tap()
    
        expectation(for: NSPredicate() {(_,_) in
            XCUIApplication().tap() // this is the magic tap that makes it work
            return hasDismissedSystemAlert
        }, evaluatedWith: NSNull(), handler: nil)
        
        waitForExpectations(timeout: 10) { (error: Error?) -> Void in
        }
        removeUIInterruptionMonitor(handler)
        
        self.waitForElementToAppear(element: app.buttons.firstMatch, timeout: 10)
    }
    
    func testPayPalViewCanBeCancelled() {
        
        let app = XCUIApplication()
        
        var hasDismissedSystemAlert = false
        let handler = addUIInterruptionMonitor(withDescription: "System Alert") {
            (alert) -> Bool in
            
            // Click the second button in dialog
            #warning("dismissing SystemAlert of type SFAuthenticationsession is unreliable")
            let button = alert.buttons.element(boundBy: 1)
            if button.exists {
                button.tap()
            }
            hasDismissedSystemAlert = true
            return true
        }
        
        app.tabBars.buttons["Bookmarks"].tap()
        app.buttons["Trigger Register UI"].tap()
        
        let payPalCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "PayPal")).element
        payPalCell.tap()
        
        expectation(for: NSPredicate() {(_,_) in
            XCUIApplication().tap() // this is the magic tap that makes it work
            return hasDismissedSystemAlert
        }, evaluatedWith: NSNull(), handler: nil)
        
        waitForExpectations(timeout: 10) { (error: Error?) -> Void in
        }
        removeUIInterruptionMonitor(handler)
        
        self.waitForElementToAppear(element: app.buttons.firstMatch, timeout: 10)
        
        let cancelButton = app.buttons["Cancel"]
        cancelButton.tap();
        
        self.waitForElementToAppear(element: app.tabBars.firstMatch, timeout: 10)
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Expected to return to main screen")
    }
}
