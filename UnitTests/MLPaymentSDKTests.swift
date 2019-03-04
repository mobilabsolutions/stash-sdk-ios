//
//  MLPaymentSDKTests.swift
//  MLPaymentSDKTests
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import XCTest
@testable import MobilabPaymentCore
@testable import MobilabPaymentBSPayone

class MLPaymentSDKTests: XCTestCase {
    
    
    var expectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MobilabPaymentSDK.setUp(publicToken: "PD-BS-eiXDbe3j0zixJUpWAgvh3cS4Hz", provider: MobilabPaymentBSPayone())
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreditCardBS() {
        
        expectation = self.expectation(description: "Example")
        
        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = CreditCardData(holderName: "Holder Name", cardNumber: "4111111111111111", CVV: "312", expiryMonth: 8, expiryYear: 2021)
        
        let registrationManager = MobilabPaymentSDK.createRegisterManager(delegate: self)
        registrationManager.registerCreditCard(billingData: billingData, creditCardData: creditCardData)
        
        self.waitForExpectations(timeout: 80) {error in
            XCTAssertNil(error)
        }
    }
    
//    func testAddSEPABS() {
//
//        expectation = self.expectation(description: "Example")
//
//        let billingData = MLBillingData(email: "mirza@miki.com",
//                                        firstName: "Mirza",
//                                        lastName: "Zenunovic",
//                                        address1: "Address1",
//                                        address2: "Address2",
//                                        ZIP: "817754",
//                                        city: "Cologne",
//                                        state: "None",
//                                        country: "Germany",
//                                        phone: "1231231123",
//                                        languageId: "deu")
//        let customerId = "123customer"
//
//        let sepaData = MLSEPAData(bankNumber: "PBNKDEFF", IBAN: "DE87123456781234567890")
//
//        let registerManager = MobilabPaymentSDK.createRegisterManager(delegate: self)
//        registerManager.registerSEPAAccount(billingData: billingData, sepaData: sepaData, customerID: customerId)
//
//        self.waitForExpectations(timeout: 80) { error in
//            XCTAssertNil(error)
//        }
//    }
}

extension MLPaymentSDKTests: RegistrationManagerProtocol {
    func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?) {
        self.expectation?.fulfill()
    }
    
    func registerCreditCardCompleted(paymentAlias: String?, error: MLError?) {
        self.expectation?.fulfill()
    }
}
