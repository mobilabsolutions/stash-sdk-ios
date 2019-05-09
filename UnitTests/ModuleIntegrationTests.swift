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
            return "mobilab-D4eWavRIslrUCQnnH6cn"
        }

        var supportedPaymentMethodTypes: [PaymentMethodType] {
            return [.creditCard, .sepa]
        }

        let completionResultToReturn: PaymentServiceProvider.RegistrationResult
        let registrationRequestCalledExpectation: XCTestExpectation?
        let aliasCreationDetailResult: Result<AliasCreationDetail?, MobilabPaymentError>

        init(completionResultToReturn: PaymentServiceProvider.RegistrationResult,
             registrationRequestCalledExpectation: XCTestExpectation?,
             aliasCreationDetailResult: Result<AliasCreationDetail?, MobilabPaymentError> = .success(nil)) {
            self.completionResultToReturn = completionResultToReturn
            self.registrationRequestCalledExpectation = registrationRequestCalledExpectation
            self.aliasCreationDetailResult = aliasCreationDetailResult
        }

        func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                       idempotencyKey _: String,
                                       completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
            XCTAssertTrue(registrationRequest.registrationData is RegistrationDataType,
                          "Expected registration data to be of type \(RegistrationDataType.self) but was \(type(of: registrationRequest.registrationData))")
            self.registrationRequestCalledExpectation?.fulfill()
            completion(self.completionResultToReturn)
        }

        func provideAliasCreationDetail(for _: RegistrationData, idempotencyKey _: String, completion: @escaping (Result<AliasCreationDetail?, MobilabPaymentError>) -> Void) {
            completion(self.aliasCreationDetailResult)
        }
    }

    private class TestAliasCreationDetail: AliasCreationDetail {
        let identifier: String

        init(identifier: String) {
            self.identifier = identifier
            super.init()
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.identifier = try container.decode(String.self, forKey: .identifier)
            try super.init(from: decoder)
        }

        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: .identifier)
        }

        enum CodingKeys: CodingKey {
            case identifier
        }
    }

    private struct TestCreateAliasRequest: Codable {
        let pspType: String
        let aliasDetail: TestAliasCreationDetail?
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        InternalPaymentSDK.sharedInstance.pspCoordinator.removeAllProviders()
    }

    func testHandleRegistrationRequestCalled() throws {
        let expectation = XCTestExpectation(description: "Handle registration is called")
        let module = TestModule<CreditCardData>(completionResultToReturn: .success("Test alias"),
                                                registrationRequestCalledExpectation: expectation)

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true
        configuration.useTestMode = true
        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        let creditCard = try CreditCardData(cardNumber: "4111111111111111",
                                            cvv: "123", expiryMonth: 9, expiryYear: 21, holderName: name.fullName, country: "Germany", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { _ in () }

        wait(for: [expectation], timeout: 5)
    }

    func testModuleFailurePropagatedCorrectly() throws {
        let calledExpectation = XCTestExpectation(description: "Handle registration is called")
        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        let errorDetails = GenericErrorDetails(description: "Sample error")
        let error = MobilabPaymentError.other(errorDetails)
        let module = TestModule<CreditCardData>(completionResultToReturn: .failure(error),
                                                registrationRequestCalledExpectation: calledExpectation)

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.useTestMode = true

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        let creditCard = try CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                            expiryMonth: 9, expiryYear: 21, holderName: name.fullName, country: "Germany", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { result in
            switch result {
            case .success:
                XCTFail("Should not have returned success when module fails")
            case let .failure(propagatedError):
                guard case .other = propagatedError
                else { XCTFail("Propagated error should be the same as the module error"); return }
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
        configuration.useTestMode = true
        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                   expiryMonth: 9, expiryYear: 21, holderName: name.fullName, country: "Germany", billingData: BillingData())
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
                ? "core_update_alias_success.json"
                : "core_create_alias_success.json"

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
                let errorDetails = GenericErrorDetails(description: "Request should have test header set to true for this test")
                return OHHTTPStubsResponse(error: MobilabPaymentError.other(errorDetails))
            }
        }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: paymentEndpoint)
        configuration.useTestMode = true
        configuration.loggingEnabled = true

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        let creditCard = try CreditCardData(cardNumber: "4111111111111111",
                                            cvv: "123", expiryMonth: 9, expiryYear: 21, holderName: name.fullName, country: "Germany", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { _ in () }

        wait(for: [expectation, stubExpectation], timeout: 5)
    }

    func testPropagatesAliasCreationDetail() throws {
        let paymentEndpoint = "https://payment-dev.mblb.net/api/v1"
        let creationDetailIdentifier = "my-creation-detail-id"

        let module = TestModule<CreditCardData>(completionResultToReturn: .success("Test alias"),
                                                registrationRequestCalledExpectation: nil,
                                                aliasCreationDetailResult: .success(TestAliasCreationDetail(identifier: creationDetailIdentifier)))

        let stubExpectation = XCTestExpectation(description: "Includes correct creation alias")

        stub(condition: { request -> Bool in
            guard let requestHost = request.url?.host,
                let expectedHost = URL(string: paymentEndpoint)?.host,
                requestHost == expectedHost
            else { return false }

            guard let httpBody = request.ohhttpStubs_httpBody,
                let request = try? JSONDecoder().decode(TestCreateAliasRequest.self, from: httpBody)
            else {
                XCTFail("Request should have an http body")
                stubExpectation.fulfill()
                return false
            }

            if let creationDetail = request.aliasDetail {
                XCTAssertEqual(creationDetail.identifier, creationDetailIdentifier)
            } else {
                XCTFail("Create alias request with alias creation detail should send the detail in its http body")
            }

            stubExpectation.fulfill()

            return true
        }) { _ -> OHHTTPStubsResponse in
            OHHTTPStubsResponse(error: MobilabPaymentError.other(GenericErrorDetails(description: "Sample error")))
        }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: paymentEndpoint)
        configuration.useTestMode = true
        configuration.loggingEnabled = true

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        let creditCard = try CreditCardData(cardNumber: "4111111111111111",
                                            cvv: "123", expiryMonth: 9, expiryYear: 21, holderName: name.fullName, country: "Germany", billingData: BillingData())

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { _ in () }

        wait(for: [stubExpectation], timeout: 5)
    }

    func testPropagatesAliasCreationDetailError() {
        let resultExpectation = XCTestExpectation(description: "Error result is propagated to the SDK user")
        let doesNotCallRegistration = XCTestExpectation(description: "Should not call registration flow when creating an alias fails")
        doesNotCallRegistration.isInverted = true

        let error = MobilabPaymentError.other(GenericErrorDetails(description: "An error occurred"))

        let module = TestModule<CreditCardData>(completionResultToReturn: .success("This should not be returned"),
                                                registrationRequestCalledExpectation: doesNotCallRegistration,
                                                aliasCreationDetailResult: .failure(error))

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.useTestMode = true
        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.registerProvider(provider: module, forPaymentMethodTypes: .creditCard)

        self.module = module

        let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")

        guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                                   expiryMonth: 9, expiryYear: 21, holderName: name.fullName, country: "Germany", billingData: BillingData())
        else { XCTFail("Credit Card data should be valid"); return }

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard) { result in
            if case .success = result {
                XCTFail("Should not have returned success when creating an alias fails")
            }

            resultExpectation.fulfill()
        }

        wait(for: [doesNotCallRegistration, resultExpectation], timeout: 2, enforceOrder: true)
    }
}
