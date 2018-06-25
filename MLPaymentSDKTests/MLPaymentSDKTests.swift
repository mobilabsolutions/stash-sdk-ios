//
//  MLPaymentSDKTests.swift
//  MLPaymentSDKTests
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import XCTest
@testable import MLPaymentSDK

class MLPaymentSDKTests: XCTestCase {
    
    
    var expectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MLPaymentSDK.setUp(publicToken: "BS")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        expectation = self.expectation(description: "Example")
        
        //[self expectationWithDescription:NSStringFromSelector(_cmd)];
        
        let billingData = MLBillingData(email: "mirza@miki.com")
        let data = MLRegisterRequestData(cardMask: "visa", type: MLPaymentMethodType.MLCreditCard, oneTime: true, customerId: "123")
        let customerId = "123customer"
        
        let creditCardData = MLCreditCardData(holderName: "Holder Name", cardNumber: "4111111111111111", CVV: "312", expiryMonth: 8, expiryYear: 2021)
        
        let registerManager = MLPaymentSDK.createRegisterManager(delegate: self)
        registerManager.registerCreditCard(billingData: billingData,
                                           creditCardData: creditCardData,
                                           customerID: customerId)
        
        print(data)
        
        self.waitForExpectations(timeout: 300) {error in
            XCTAssertNil(error)
        }
        
        
       // let registerManager = MLPaymentSDK.createPaymentManager(delegate: self)
       // registerManager.registerCreditCard()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

//@objc protocol MLRegisterManagerProtocol: class {
//    @objc func registerCreditCardCompleted(paymentAlias: String?, error: MLError?)
//    @objc func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?)
//    @objc func removeCreditCardCompleted(error: MLError?)
//    @objc func removeSEPACompleted(error: MLError?)
//}

extension MLPaymentSDKTests: MLRegisterManagerProtocol {
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
