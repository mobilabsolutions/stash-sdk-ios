//
import OHHTTPStubs
//  AdyenIntegrationTests.swift
//  StashTests
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//
@testable import StashAdyen
@testable import StashCore
import XCTest

class AdyenIntegrationTests: XCTestCase {
    private var provider: PaymentServiceProvider?

    override func setUp() {
        super.setUp()

        SDKResetter.resetStash()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let provider = StashAdyen()
        self.provider = provider

        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-dev.mblb.net/api/v1",
                                               integrations: [PaymentProviderIntegration(paymentServiceProvider: provider)])
        configuration.loggingLevel = .normal
        configuration.useTestMode = true

        Stash.initialize(configuration: configuration)

        OHHTTPStubs.removeAllStubs()
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        SDKResetter.resetStash()
    }

    func testCreditCard() throws {
        let expectation = self.expectation(description: "Registering credit card succeeds")

        let billingData = BillingData(email: "mirza@miki.com", name: SimpleNameProvider(firstName: "Holder", lastName: "Name"))
        let creditCardData = try CreditCardData(cardNumber: "2222 4000 1000 0008", cvv: "737", expiryMonth: 10, expiryYear: 20,
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
        else { XCTFail("Could not get supported payment method types for UI from Adyen provider"); return }

        XCTAssertEqual(expected, Set(supported), "Adyen should allow UI payment methods: \(expected) but allows: \(supported)")
    }

    func testCorrectlyPropagatesAdyenError() {
        stub(condition: isHost("payment-dev.mblb.net")) { request -> OHHTTPStubsResponse in

            let requestSuccessFile = request.httpMethod == StashCore.HTTPMethod.PUT.rawValue
                ? "core_update_alias_success.json"
                : "core_create_alias_adyen_success.json"

            guard let path = OHPathForFile(requestSuccessFile, type(of: self))
            else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
        let billingData = BillingData(name: name)

        guard let expired = try? CreditCardData(cardNumber: "2222 4000 1000 0008", cvv: "123",
                                                expiryMonth: 9, expiryYear: 0, country: "DE", billingData: billingData)
        else { XCTFail("Credit Card data should be valid"); return }

        Stash.getRegistrationManager().registerCreditCard(creditCardData: expired) { result in
            switch result {
            case .success: XCTFail("Should not have returned success when creating an alias fails")
            case let .failure(error):
                guard case StashError.configuration = error
                else { XCTFail("An error in the PSP should be propagated as a pspError"); break }
            }

            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: 20)
    }
}
