//
//  MLPaymentSDKTests.swift
//  MLPaymentSDKTests
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import OHHTTPStubs
@testable import StashBSPayone
@testable import StashCore
import XCTest

class BSPayoneIntegrationTests: XCTestCase {
    private var provider: PaymentServiceProvider?
    private let bsPayoneHost = "secure.pay1.de"

    override func setUp() {
        super.setUp()

        OHHTTPStubs.removeAllStubs()
        SDKResetter.resetStash()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let provider = StashBSPayone()
        self.provider = provider

        let integration = PaymentProviderIntegration(paymentServiceProvider: provider)
        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-demo.mblb.net/api/v1",
                                               integrations: [integration])
        configuration.loggingEnabled = true
        configuration.useTestMode = true

        Stash.initialize(configuration: configuration)
    }

    override func tearDown() {
        super.tearDown()
        SDKResetter.resetStash()
        OHHTTPStubs.removeAllStubs()
    }

    func testCreditCard() throws {
        stub(condition: isHost(self.bsPayoneHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("bs_credit_card_success.json", type(of: self))
            else { Swift.fatalError("Expected file bs_credit_card_success.json to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let expectation = self.expectation(description: "Registering credit card succeeds")

        let billingData = BillingData(email: "mirza@miki.com", name: SimpleNameProvider(firstName: "Holder", lastName: "Name"))
        let creditCardData = try CreditCardData(cardNumber: "4111111111111111", cvv: "312", expiryMonth: 08, expiryYear: 21,
                                                country: "DE", billingData: billingData)

        let registrationManager = Stash.getRegistrationManager()
        registrationManager.registerCreditCard(creditCardData: creditCardData, completion: { result in
            switch result {
            case .success: expectation.fulfill()
            case let .failure(error):
                XCTFail("An error occurred while adding a credit card: \(error.description)")
                expectation.fulfill()
            }
        })

        waitForExpectations(timeout: 20)
    }

    func testAddSEPA() throws {
        stub(condition: isHost(self.bsPayoneHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("bs_sepa_success.json", type(of: self))
            else { Swift.fatalError("Expected file bs_sepa_success.json to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let expectation = self.expectation(description: "Registering SEPA succeeds")

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        let billingData = BillingData(email: "max@mustermann.de",
                                      name: name,
                                      address1: "Address1",
                                      address2: "Address2",
                                      zip: "817754",
                                      city: "Cologne",
                                      state: nil,
                                      country: "DE",
                                      phone: "1231231123",
                                      languageId: "deu")

        let sepaData = try SEPAData(iban: "DE75512108001245126199", bic: "COLSDE33XXX", billingData: billingData)

        let registerManager = Stash.getRegistrationManager()
        registerManager.registerSEPAAccount(sepaData: sepaData) { result in
            switch result {
            case .success: expectation.fulfill()
            case let .failure(error):
                XCTFail("An error occurred while adding SEPA: \(error.description)")
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 20)
    }

    func testHasCorrectPaymentMethodUITypes() {
        let expected: Set = [PaymentMethodType.creditCard, PaymentMethodType.sepa]

        guard let supported = provider?.supportedPaymentMethodTypeUserInterfaces
        else { XCTFail("Could not get supported payment method types for UI from BS provider"); return }

        XCTAssertEqual(expected, Set(supported), "BSPayone should allow UI payment methods: \(expected) but allows: \(supported)")
    }

    func testCorrectlyPropagatesBSError() {
        stub(condition: isHost(self.bsPayoneHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("bs_credit_card_failure.json", type(of: self))
            else { Swift.fatalError("Expected file bs_credit_card_failure.json to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
        let billingData = BillingData(name: name)

        guard let expired = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                expiryMonth: 9, expiryYear: 0, country: "DE", billingData: billingData)
        else { XCTFail("Credit Card data should be valid"); return }

        Stash.getRegistrationManager().registerCreditCard(creditCardData: expired) { result in
            switch result {
            case .success: XCTFail("Should not have returned success when creating an alias fails")
            case let .failure(error):
                guard case StashError.validation = error
                else { XCTFail("An error in the PSP should be propagated as a pspError"); break }
            }

            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: 20)
    }

    func testCorrectlyPropagatesTemporaryBSError() {
        stub(condition: isHost(self.bsPayoneHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("bs_credit_card_temp_failure.json", type(of: self))
            else { Swift.fatalError("Expected file bs_credit_card_temp_failure.json to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
        let billingData = BillingData(name: name)

        guard let expired = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                expiryMonth: 9, expiryYear: 0, country: "DE", billingData: billingData)
        else { XCTFail("Credit Card data should be valid"); return }

        Stash.getRegistrationManager().registerCreditCard(creditCardData: expired) { result in
            switch result {
            case .success: XCTFail("Should not have returned success when creating an alias fails")
            case let .failure(error):
                guard case StashError.temporary = error
                else { XCTFail("An error in the PSP should be propagated as a pspTemporaryError"); break }
            }

            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: 20)
    }
}
