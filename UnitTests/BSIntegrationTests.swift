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

class BSIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MobilabPaymentSDK.setUp(provider: MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"))
    }

    func testCreditCardBS() {
        let expectation = self.expectation(description: "Registering credit card succeeds")

        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = CreditCardData(cardNumber: "4111111111111111", cvv: "312", expiryMonth: 08, expiryYear: 21, holderName: "Holder Name", billingData: billingData)

        let registrationManager = MobilabPaymentSDK.getRegisterManager()
        registrationManager.registerCreditCard(creditCardData: creditCardData, completion: { result in
            switch result {
            case .success: expectation.fulfill()
            case let .failure(error):
                XCTFail("An error occurred while adding a credit card: \(error.failureReason ?? "unknown error")")
                expectation.fulfill()
            }
        })

        waitForExpectations(timeout: 20) { error in
            XCTAssertNil(error)
        }
    }

    func testErrorCompletionWhenCreditCardIsOfUnknownType() {
        let expectation = self.expectation(description: "Registering invalid credit card fails")

        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = CreditCardData(cardNumber: "123 1111 1111 1111", cvv: "312", expiryMonth: 08, expiryYear: 21, holderName: "Holder Name", billingData: billingData)

        XCTAssertEqual(creditCardData.cardType, .unknown)

        let registrationManager = MobilabPaymentSDK.getRegisterManager()
        registrationManager.registerCreditCard(creditCardData: creditCardData, completion: { result in
            switch result {
            case .success:
                XCTFail("Adding an invalid credit card should not succeed")
                expectation.fulfill()
            case .failure:
                expectation.fulfill()
            }
        })

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testAddSEPABS() {
        let expectation = self.expectation(description: "Registering SEPA succeeds")

        let billingData = BillingData(email: "max@mustermann.de",
                                      name: "Max Mustermann",
                                      address1: "Address1",
                                      address2: "Address2",
                                      zip: "817754",
                                      city: "Cologne",
                                      state: nil,
                                      country: "Germany",
                                      phone: "1231231123",
                                      languageId: "deu")

        let sepaData = SEPAData(iban: "PBNKDEFF", bic: "DE87123456781234567890", billingData: billingData)

        let registerManager = MobilabPaymentSDK.getRegisterManager()
        registerManager.registerSEPAAccount(sepaData: sepaData) { result in
            switch result {
            case .success: expectation.fulfill()
            case let .failure(error):
                XCTFail("An error occurred while adding SEPA: \(error.failureReason ?? "unknown error")")
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 20) { error in
            XCTAssertNil(error)
        }
    }
}
