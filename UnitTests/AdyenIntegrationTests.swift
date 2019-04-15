//
//  AdyenIntegrationTests.swift
//  MobilabPaymentTests
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//
@testable import MobilabPaymentAdyen
@testable import MobilabPaymentCore
import OHHTTPStubs
import XCTest

class AdyenIntegrationTests: XCTestCase {
    private var provider: PaymentServiceProvider?

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true

        let provider = MobilabPaymentAdyen()
        self.provider = provider

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: provider, forPaymentMethodTypes: .creditCard, .sepa)
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        InternalPaymentSDK.sharedInstance.pspCoordinator.removeAllProviders()
    }

    func testCreditCard() throws {
        stub(condition: isHost("payment-dev.mblb.net")) { request -> OHHTTPStubsResponse in

            let requestSuccessFile = request.httpMethod == HTTPMethod.PUT.rawValue
                ? "core_update_alias_success.json"
                : "core_create_alias_adyen_success.json"

            guard let path = OHPathForFile(requestSuccessFile, type(of: self))
            else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let expectation = self.expectation(description: "Registering credit card succeeds")

        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = try CreditCardData(cardNumber: "4111111111111111", cvv: "312", expiryMonth: 08, expiryYear: 21,
                                                holderName: "Holder Name", billingData: billingData)

        let registrationManager = MobilabPaymentSDK.getRegistrationManager()
        registrationManager.registerCreditCard(creditCardData: creditCardData, completion: { _ in
            #warning("Update this test once Adyen is implemented on the backend side")
            expectation.fulfill()
//            switch result {
//            case .success: expectation.fulfill()
//            case let .failure(error):
//                XCTFail("An error occurred while adding a credit card: \(error.failureReason ?? "unknown error")")
//                expectation.fulfill()
//            }
        })

        waitForExpectations(timeout: 20)
    }

    func testAddSEPA() throws {
        stub(condition: isHost("payment-dev.mblb.net")) { request -> OHHTTPStubsResponse in

            let requestSuccessFile = request.httpMethod == HTTPMethod.PUT.rawValue
                ? "core_update_alias_success.json"
                : "core_create_alias_adyen_success.json"

            guard let path = OHPathForFile(requestSuccessFile, type(of: self))
            else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

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

        let registerManager = MobilabPaymentSDK.getRegistrationManager()
        registerManager.registerSEPAAccount(sepaData: sepaData) { _ in
            #warning("Update this test once Adyen is implemented on the backend side")
            expectation.fulfill()
//            switch result {
//            case .success: expectation.fulfill()
//            case let .failure(error):
//                XCTFail("An error occurred while adding SEPA: \(error.errorDescription ?? "unknown error")")
//                expectation.fulfill()
//            }
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

            let requestSuccessFile = request.httpMethod == HTTPMethod.PUT.rawValue
                ? "core_update_alias_success.json"
                : "core_create_alias_adyen_success.json"

            guard let path = OHPathForFile(requestSuccessFile, type(of: self))
            else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        guard let expired = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                expiryMonth: 9, expiryYear: 0, holderName: "Max Mustermann", billingData: BillingData())
        else { XCTFail("Credit Card data should be valid"); return }

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: expired) { _ in
            #warning("Update this test once Adyen is implemented on the backend side")
//            switch result {
//            case .success: XCTFail("Should not have returned success when creating an alias fails")
//            case let .failure(error): XCTAssertEqual(error.title, "PSP Error",
//                                                     "Expected error title \"PSP Error\" for error in Adyen PSP but got \"\(error.title)\"")
//            }

            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: 20)
    }
}
