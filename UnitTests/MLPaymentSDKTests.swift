//
//  MLPaymentSDKTests.swift
//  MLPaymentSDKTests
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

@testable import MobilabPaymentBSPayone
@testable import MobilabPaymentCore
import XCTest

class MLPaymentSDKTests: XCTestCase {
    var expectation: XCTestExpectation?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MobilabPaymentSDK.setUp(provider: MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"))
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreditCardBS() {
        self.expectation = self.expectation(description: "Example")

        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = CreditCardData(holderName: "Holder Name", cardNumber: "4111111111111111", CVV: "312", expiryMonth: 08, expiryYear: 21)

        let registrationManager = MobilabPaymentSDK.createRegisterManager(delegate: self)
        registrationManager.registerCreditCard(billingData: billingData, creditCardData: creditCardData)

        waitForExpectations(timeout: 80) { error in
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
    func registerSEPAAccountCompleted(paymentAlias _: String?, error _: MLError?) {
        self.expectation?.fulfill()
    }

    func registerCreditCardCompleted(paymentAlias _: String?, error _: MLError?) {
        self.expectation?.fulfill()
    }
}
