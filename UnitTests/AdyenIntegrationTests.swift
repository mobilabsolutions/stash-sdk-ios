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
    private let adyenHost = "checkout-test.adyen.com"

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
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

        stub(condition: isHost(self.adyenHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("adyen_credit_card_success.json", type(of: self))
            else { Swift.fatalError("Expected file adyen_credit_card_success.json to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let expectation = self.expectation(description: "Registering credit card succeeds")

        let billingData = BillingData(email: "mirza@miki.com")
        let creditCardData = try CreditCardData(cardNumber: "4111111111111111", cvv: "312", expiryMonth: 08, expiryYear: 21,
                                                holderName: "Holder Name", billingData: billingData)

        let registrationManager = MobilabPaymentSDK.getRegistrationManager()
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

    func testAddSEPA() throws {
        stub(condition: isHost("payment-dev.mblb.net")) { request -> OHHTTPStubsResponse in

            let requestSuccessFile = request.httpMethod == HTTPMethod.PUT.rawValue
                ? "core_update_alias_success.json"
                : "core_create_alias_adyen_success.json"

            guard let path = OHPathForFile(requestSuccessFile, type(of: self))
            else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        stub(condition: isHost(self.adyenHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("adyen_sepa_success.json", type(of: self))
            else { Swift.fatalError("Expected file adyen_sepa_success.json to exist.") }
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

    func testCorrectlyPropagatesAdyenError() {
        stub(condition: isHost("payment-dev.mblb.net")) { request -> OHHTTPStubsResponse in

            let requestSuccessFile = request.httpMethod == HTTPMethod.PUT.rawValue
                ? "core_update_alias_success.json"
                : "core_create_alias_adyen_success.json"

            guard let path = OHPathForFile(requestSuccessFile, type(of: self))
            else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        stub(condition: isHost(self.adyenHost)) { _ -> OHHTTPStubsResponse in
            guard let path = OHPathForFile("adyen_credit_card_failure.json", type(of: self))
            else { Swift.fatalError("Expected file adyen_credit_card_failure.json to exist.") }
            return fixture(filePath: path, status: 200, headers: [:])
        }

        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        guard let expired = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                expiryMonth: 9, expiryYear: 0, holderName: "Max Mustermann", billingData: BillingData())
        else { XCTFail("Credit Card data should be valid"); return }

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: expired) { result in
            switch result {
            case .success: XCTFail("Should not have returned success when creating an alias fails")
            case let .failure(error): XCTAssertEqual(error.title, "PSP Error")
            }

            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: 20)
    }
}
