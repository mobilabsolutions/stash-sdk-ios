//
//  ModuleIntegrationTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import OHHTTPStubs
import XCTest

class ModuleIntegrationTests: XCTestCase {
    private var module: PaymentServiceProvider?

    private class TestModule<RegistrationDataType: RegistrationData>: PaymentServiceProvider {
        var pspIdentifier: MobilabPaymentProvider {
            return .bsPayone
        }

        var publicKey: String {
            return "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"
        }

        var supportedPaymentMethodTypes: [PaymentMethodType] {
            return [.creditCard, .sepa]
        }

        let completionResultToReturn: PaymentServiceProvider.RegistrationResult
        let registrationRequestCalledExpectation: XCTestExpectation?

        init(completionResultToReturn: PaymentServiceProvider.RegistrationResult,
             registrationRequestCalledExpectation: XCTestExpectation?) {
            self.completionResultToReturn = completionResultToReturn
            self.registrationRequestCalledExpectation = registrationRequestCalledExpectation
        }

        func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                       completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
            XCTAssertTrue(registrationRequest.registrationData is RegistrationDataType)
            self.registrationRequestCalledExpectation?.fulfill()
            completion(self.completionResultToReturn)
        }
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testHandleRegistrationRequestCalled() throws {
        let expectation = XCTestExpectation(description: "Handle registration is called")
        let module = TestModule<CreditCardData>(completionResultToReturn: .success("Test alias"),
                                                registrationRequestCalledExpectation: expectation)

        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true
        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let creditCard = try CreditCardData(cardNumber: "4111111111111111",
                                            cvv: "123", expiryMonth: 9, expiryYear: 21, holderName: "Max Mustermann", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { _ in () }

        wait(for: [expectation], timeout: 5)
    }

    func testModuleFailurePropagatedCorrectly() throws {
        let calledExpectation = XCTestExpectation(description: "Handle registration is called")
        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        let error = MLError(title: "Test Failure",
                            description: "Sample test failure", code: 123)
        let module = TestModule<CreditCardData>(completionResultToReturn: .failure(error),
                                                registrationRequestCalledExpectation: calledExpectation)

        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let creditCard = try CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                            expiryMonth: 9, expiryYear: 21, holderName: "Max Mustermann", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { result in
            switch result {
            case .success:
                XCTFail("Should not have returned success when module fails")
            case let .failure(propagatedError):
                XCTAssertEqual(error.code, propagatedError.code)
            }

            resultExpectation.fulfill()
        }

        wait(for: [calledExpectation, resultExpectation], timeout: 5, enforceOrder: true)
    }

    func testCreateAliasFailurePropagatedCorrectly() {
        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")
        let doesNotCallRegistration = XCTestExpectation(description: "Should not call registration flow when creating an alias fails")
        doesNotCallRegistration.isInverted = true

        let module = TestModule<CreditCardData>(completionResultToReturn: .success("This should not be returned"), registrationRequestCalledExpectation: doesNotCallRegistration)

        let configuration = MobilabPaymentConfiguration(publicKey: "incorrect-test-key", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                   expiryMonth: 9, expiryYear: 21, holderName: "Max Mustermann", billingData: BillingData())
        else { XCTFail("Credit Card data should be valid"); return }

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { result in
            if case .success = result {
                XCTFail("Should not have returned success when creating an alias fails")
            }
            resultExpectation.fulfill()
        }

        wait(for: [doesNotCallRegistration, resultExpectation], timeout: 2, enforceOrder: true)
    }

    func testCreatedAndUpdatedAliasWithTestMode() throws {
        let paymentEndpoint = "https://payment-dev.mblb.net/api/v1"

        let expectation = XCTestExpectation(description: "Handle registration is called")
        let module = TestModule<CreditCardData>(completionResultToReturn: .success("Test alias"),
                                                registrationRequestCalledExpectation: expectation)

        let stubExpectation = XCTestExpectation(description: "Includes correct test header for create and update alias")
        stubExpectation.expectedFulfillmentCount = 2

        stub(condition: { request -> Bool in
            guard let requestHost = request.url?.host,
                let expectedHost = URL(string: paymentEndpoint)?.host,
                requestHost == expectedHost
            else { return false }
            return true
        }) { request -> OHHTTPStubsResponse in

            let requestSuccessFile = request.httpMethod == HTTPMethod.PUT.rawValue
                ? "update_alias_success.json"
                : "create_alias_success.json"

            if let isTestString = request.allHTTPHeaderFields?["PSP-Test-Mode"],
                let isTest = Bool(isTestString),
                isTest {
                guard let path = OHPathForFile(requestSuccessFile, type(of: self))
                else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }

                stubExpectation.fulfill()
                return fixture(filePath: path, status: 200, headers: [:])
            } else {
                XCTFail("Should have test header and test header should have value of true")
                stubExpectation.fulfill()
                return OHHTTPStubsResponse(error: MLError(title: "Wrong request sent", description: "Request should have test header set to true", code: -123))
            }
        }

        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: paymentEndpoint)
        configuration.useTestMode = true

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let creditCard = try CreditCardData(cardNumber: "4111111111111111",
                                            cvv: "123", expiryMonth: 9, expiryYear: 21, holderName: "Max Mustermann", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { _ in () }

        wait(for: [expectation, stubExpectation], timeout: 5)
    }
}
