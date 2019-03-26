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

class BSPayoneIntegrationTests: XCTestCase {
    private var provider: PaymentServiceProvider?

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true

        let provider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")
        self.provider = provider

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: provider, forPaymentMethodTypes: .creditCard, .sepa)
    }

    func testCreditCardBS() throws {
        let expectation = self.expectation(description: "Registering credit card succeeds")

        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = try CreditCardData(cardNumber: "4111111111111111", cvv: "312", expiryMonth: 08, expiryYear: 21,
                                                holderName: "Holder Name", billingData: billingData)

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

    func testErrorCompletionWhenCreditCardIsOfUnknownType() throws {
        let expectation = self.expectation(description: "Registering invalid credit card fails")

        let creditCardData = try CreditCardData(cardNumber: "5060 6666 6666 6666 666", cvv: "312", expiryMonth: 08, expiryYear: 21,
                                                holderName: "Holder Name", billingData: BillingData())

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

    func testAddSEPABS() throws {
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

        let sepaData = try SEPAData(iban: "DE75512108001245126199", bic: "COLSDE33XXX", billingData: billingData)

        let registerManager = MobilabPaymentSDK.getRegisterManager()
        registerManager.registerSEPAAccount(sepaData: sepaData) { result in
            switch result {
            case .success: expectation.fulfill()
            case let .failure(error):
                XCTFail("An error occurred while adding SEPA: \(error.errorDescription ?? "unknown error")")
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 20) { error in
            XCTAssertNil(error)
        }
    }

    func testHasCorrectPaymentMethodUITypes() {
        let expected = [PaymentMethodType.creditCard, PaymentMethodType.sepa]

        XCTAssertEqual(expected.count, provider?.supportedPaymentMethodTypeUserInterfaces.count)

        for value in expected {
            XCTAssertTrue(self.provider?.supportedPaymentMethodTypeUserInterfaces.contains(value) ?? false)
        }
    }

    func testCorrectlyPropagatesBSError() {
        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        guard let expired = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                expiryMonth: 9, expiryYear: 0, holderName: "Max Mustermann", billingData: BillingData())
        else { XCTFail("Credit Card data should be valid"); return }

        MobilabPaymentSDK.getRegisterManager().registerCreditCard(creditCardData: expired) { result in
            switch result {
            case .success: XCTFail("Should not have returned success when creating an alias fails")
            case let .failure(error): XCTAssertEqual(error.title, "PSP Error")
            }

            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: 20)
    }
}
