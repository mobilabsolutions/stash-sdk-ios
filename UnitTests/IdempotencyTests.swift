//
//  IdempotencyTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 26.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@testable import MobilabPaymentCore
import OHHTTPStubs
import XCTest

class IdempotencyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SDKResetter.resetMobilabSDK()
        OHHTTPStubs.removeAllStubs()
    }

    override func tearDown() {
        super.tearDown()
        SDKResetter.resetMobilabSDK()
        OHHTTPStubs.removeAllStubs()
    }

    private class TestModule: PaymentServiceProvider {
        var pspIdentifier: MobilabPaymentProvider {
            return .bsPayone
        }

        var publicKey: String {
            return "mobilab-D4eWavRIslrUCQnnH6cn"
        }

        var supportedPaymentMethodTypes: [PaymentMethodType] {
            return [.creditCard, .sepa]
        }

        private var handleRegistrationRequestCallback: (RegistrationRequest, String) -> PaymentServiceProvider.RegistrationResult
        private var handleAliasCreationDetailCallback: (RegistrationData, String) -> Result<AliasCreationDetail?, MobilabPaymentError>

        init(handleRegistrationRequestCallback: @escaping (RegistrationRequest, String) -> PaymentServiceProvider.RegistrationResult,
             handleAliasCreationDetailCallback: @escaping (RegistrationData, String) -> Result<AliasCreationDetail?, MobilabPaymentError>) {
            self.handleAliasCreationDetailCallback = handleAliasCreationDetailCallback
            self.handleRegistrationRequestCallback = handleRegistrationRequestCallback
        }

        func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                       idempotencyKey: String,
                                       completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
            completion(self.handleRegistrationRequestCallback(registrationRequest, idempotencyKey))
        }

        func provideAliasCreationDetail(for data: RegistrationData, idempotencyKey: String, completion: @escaping (Result<AliasCreationDetail?, MobilabPaymentError>) -> Void) {
            completion(self.handleAliasCreationDetailCallback(data, idempotencyKey))
        }
    }

    func testPropagatesIdempotencyKeyToModule() throws {
        let providedIdempotencyKey = UUID().uuidString

        let providesIdempotencyKeyToAliasCreationDetail = XCTestExpectation(description: "The SDK should propagate the same idempotency key to the alias creation detail request")
        let providesIdempotencyKeyToRegistration = XCTestExpectation(description: "The SDK should propagate the same idempotency key to the registration request")

        let module = TestModule(handleRegistrationRequestCallback: { _, idempotencyKey in
            XCTAssertEqual(idempotencyKey, providedIdempotencyKey, "The provided idempotency key \(providedIdempotencyKey) should match the propagated idempotency key \(idempotencyKey) for registration request")
            providesIdempotencyKeyToRegistration.fulfill()
            return .failure(.other(GenericErrorDetails(description: "Generic Error to stop the payment method creation process here")))
        }, handleAliasCreationDetailCallback: { _, idempotencyKey in
            XCTAssertEqual(idempotencyKey, providedIdempotencyKey, "The provided idempotency key \(providedIdempotencyKey) should match the propagated idempotency key \(idempotencyKey) for alias creation detail request")
            providesIdempotencyKeyToAliasCreationDetail.fulfill()
            return .success(nil)
        })

        let integration = PaymentProviderIntegration(paymentServiceProvider: module)
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [integration])
        MobilabPaymentSDK.initialize(configuration: configuration)

        let creditCard = try CreditCardData(cardNumber: "4111111111111111", cvv: "123", expiryMonth: 10, expiryYear: 21, country: "DE", billingData: BillingData())
        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard, idempotencyKey: providedIdempotencyKey) { _ in
            // Intentionally left empty
        }

        self.wait(for: [providesIdempotencyKeyToAliasCreationDetail, providesIdempotencyKeyToRegistration], timeout: 5, enforceOrder: true)
    }

    func testPropagatesProvidedIdempotencyKeyToBackend() throws {
        let providedIdempotencyKey = UUID().uuidString

        let providesIdempotencyKeyToCreateAlias = XCTestExpectation(description: "The SDK should propagate the same idempotency key to the alias creation endpoint")
        let providesIdempotencyKeyToUpdateAlias = XCTestExpectation(description: "The SDK should propagate the same idempotency key to the update alias endpoint")

        let creditCard = try CreditCardData(cardNumber: "4111111111111111", cvv: "123", expiryMonth: 10,
                                            expiryYear: 21, country: "DE", billingData: BillingData())

        let module = TestModule(handleRegistrationRequestCallback: { _, _ in
            let aliasExtra = AliasExtra(ccConfig: CreditCardExtra(ccExpiry: "10/21", ccMask: "1111", ccType: "VISA", ccHolderName: nil), billingData: BillingData())
            return .success(PSPRegistration(pspAlias: nil, aliasExtra: aliasExtra))
        }, handleAliasCreationDetailCallback: { _, _ in
            .success(nil)
        })

        let integration = PaymentProviderIntegration(paymentServiceProvider: module)
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [integration])
        MobilabPaymentSDK.initialize(configuration: configuration)

        let paymentEndpoint = "https://payment-dev.mblb.net/api/v1"

        stub(condition: { request -> Bool in
            guard let requestHost = request.url?.host,
                let expectedHost = URL(string: paymentEndpoint)?.host,
                requestHost == expectedHost
            else { return false }
            return true
        }) { request -> OHHTTPStubsResponse in

            let isCreateRequest = request.httpMethod == HTTPMethod.POST.rawValue
            let requestSuccessFile = isCreateRequest
                ? "core_create_alias_success.json"
                : "core_update_alias_success.json"

            let response: OHHTTPStubsResponse

            if let idempotencyKeyHeader = request.allHTTPHeaderFields?["Idempotent-Key"] {
                XCTAssertEqual(idempotencyKeyHeader, providedIdempotencyKey, "The idempotency key in the header should equal the provided one. Instead provided: \(providedIdempotencyKey), in header: \(idempotencyKeyHeader)")
                guard let path = OHPathForFile(requestSuccessFile, type(of: self))
                else { Swift.fatalError("Expected file \(requestSuccessFile) to exist.") }

                response = fixture(filePath: path, status: 200, headers: [:])
            } else {
                XCTFail("No idempotency key header provided. Headers: \(request.allHTTPHeaderFields?.description ?? "nil")")
                response = OHHTTPStubsResponse(error: MobilabPaymentError.other(GenericErrorDetails(description: "There should have been an idempotency key header")))
            }

            if isCreateRequest {
                providesIdempotencyKeyToCreateAlias.fulfill()
            } else {
                providesIdempotencyKeyToUpdateAlias.fulfill()
            }

            return response
        }

        MobilabPaymentSDK.getRegistrationManager().registerCreditCard(creditCardData: creditCard, idempotencyKey: providedIdempotencyKey) { _ in
            // Intentionally left empty
        }

        self.wait(for: [providesIdempotencyKeyToCreateAlias, providesIdempotencyKeyToUpdateAlias], timeout: 5, enforceOrder: true)
    }
}
