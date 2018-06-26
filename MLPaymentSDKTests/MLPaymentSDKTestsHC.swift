//
//  MLPaymentSDKTestsHC.swift
//  MLPaymentSDKTests
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import XCTest
@testable import MLPaymentSDK

class MLPaymentSDKTestsHC: XCTestCase {
    
     var expectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        MLPaymentSDK.setUp(publicToken: "PD-HC-nhnEiKIFQiZeVjGCM0HZY3xvaI")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddCreditCard() {
        
        expectation = self.expectation(description: "Example")
        
        let billingData = MLBillingData(email: "mirza@miki.com")
        let data = MLRegisterRequestData(cardMask: "visa", type: MLPaymentMethodType.MLCreditCard, oneTime: true, customerId: "123")
        let customerId = "123customer"
        
        let failCC = "4111111111111111"
        let successCC = "4200000000000000"
        let creditCardData = MLCreditCardData(holderName: "Holder Name", cardNumber: failCC, CVV: "312", expiryMonth: 8, expiryYear: 2021)
        
        let registerManager = MLPaymentSDK.createRegisterManager(delegate: self)
        registerManager.registerCreditCard(billingData: billingData,
                                           creditCardData: creditCardData,
                                           customerID: customerId)
        
        print(data)
        
        self.waitForExpectations(timeout: 300) {error in
            XCTAssertNil(error)
        }
    }
}

extension MLPaymentSDKTestsHC: MLRegisterManagerProtocol {
    func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?) {
        
    }
    
    func removeCreditCardCompleted(error: MLError?) {
        
    }
    
    func removeSEPACompleted(error: MLError?) {
        
    }
    
    func registerCreditCardCompleted(paymentAlias: String?, error: MLError?) {
        self.expectation?.fulfill()
        print(paymentAlias)
    }
}
