//
//  PaymentMethodIntegrationTests.swift
//  StashTests
//
//  Created by Robert on 19.07.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashAdyen
import StashBSPayone
import StashCore
import XCTest

class PaymentMethodIntegrationTests: XCTestCase {
    private let backend = TestMerchantBackend()

    override func setUp() {
        SDKResetter.resetStash()
    }

    override func tearDown() {
        SDKResetter.resetStash()
    }

    func testCanCreateBSPayoneCreditCard() throws {
        self.initializeSDKForBSPayone()
        let registrationManager = Stash.getRegistrationManager()

        let creditCard = try CreditCardData(cardNumber: "5453010000080200",
                                            cvv: "123",
                                            expiryMonth: 10,
                                            expiryYear: 20,
                                            country: "DE",
                                            billingData: BillingData(name: SimpleNameProvider(firstName: "Max", lastName: "Mustermann")))

        let canRegisterExpectation = expectation(description: "Can register a CC account with BS Payone")
        canRegisterExpectation.expectedFulfillmentCount = 1

        let canCreateWithBackendExpectation = expectation(description: "Can create the registered CC payment method with the merchant backend")
        canCreateWithBackendExpectation.expectedFulfillmentCount = 1

        let canAuthorizePaymentExpectation = expectation(description: "Can authorize payment for BS Payone CC payment method")
        canAuthorizePaymentExpectation.expectedFulfillmentCount = 1

        registrationManager.registerCreditCard(creditCardData: creditCard) { result in
            self.registerAndPayWithPaymentMethod(registrationResult: result,
                                                 paymentMethodType: "CC",
                                                 pspName: "BS Payone",
                                                 canCreateMethodExpectation: canCreateWithBackendExpectation,
                                                 canAuthorizePaymentExpectation: canAuthorizePaymentExpectation)
            canRegisterExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCanCreateBSPayoneSEPAMethod() throws {
        self.initializeSDKForBSPayone()
        let registrationManager = Stash.getRegistrationManager()

        let sepa = try SEPAData(iban: "DE85123456782599100003",
                                bic: "TESTTEST",
                                billingData: BillingData(name: SimpleNameProvider(firstName: "Christina", lastName: "Schneider"), country: "DE"))

        let canRegisterExpectation = expectation(description: "Can register a SEPA account with BS Payone")
        canRegisterExpectation.expectedFulfillmentCount = 1

        let canCreateWithBackendExpectation = expectation(description: "Can create the registered SEPA payment method with the merchant backend")
        canCreateWithBackendExpectation.expectedFulfillmentCount = 1

        let canAuthorizePaymentExpectation = expectation(description: "Can authorize payment for BS Payone SEPA payment method")
        canAuthorizePaymentExpectation.expectedFulfillmentCount = 1

        registrationManager.registerSEPAAccount(sepaData: sepa) { result in
            self.registerAndPayWithPaymentMethod(registrationResult: result,
                                                 paymentMethodType: "SEPA",
                                                 pspName: "BS Payone",
                                                 canCreateMethodExpectation: canCreateWithBackendExpectation,
                                                 canAuthorizePaymentExpectation: canAuthorizePaymentExpectation)
            canRegisterExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCanCreateAdyenCreditCard() throws {
        self.initializeSDKForAdyen()
        let registrationManager = Stash.getRegistrationManager()

        let creditCard = try CreditCardData(cardNumber: "6011 6011 6011 6611",
                                            cvv: "737",
                                            expiryMonth: 10,
                                            expiryYear: 20,
                                            country: nil,
                                            billingData: BillingData(name: SimpleNameProvider(firstName: "Max", lastName: "Mustermann")))

        let canRegisterExpectation = expectation(description: "Can register a CC account with Adyen")
        canRegisterExpectation.expectedFulfillmentCount = 1

        let canCreateWithBackendExpectation = expectation(description: "Can create the registered CC payment method with the merchant backend")
        canCreateWithBackendExpectation.expectedFulfillmentCount = 1

        let canAuthorizePaymentExpectation = expectation(description: "Can authorize payment for Adyen CC payment method")
        canAuthorizePaymentExpectation.expectedFulfillmentCount = 1

        registrationManager.registerCreditCard(creditCardData: creditCard) { result in
            self.registerAndPayWithPaymentMethod(registrationResult: result,
                                                 paymentMethodType: "CC",
                                                 pspName: "Adyen",
                                                 canCreateMethodExpectation: canCreateWithBackendExpectation,
                                                 canAuthorizePaymentExpectation: canAuthorizePaymentExpectation)
            canRegisterExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCanCreateAdyenSEPAMethod() throws {
        self.initializeSDKForAdyen()
        let registrationManager = Stash.getRegistrationManager()

        let sepa = try SEPAData(iban: "DE14123456780023456789",
                                bic: nil,
                                billingData: BillingData(name: SimpleNameProvider(firstName: "Christina", lastName: "Schneider")))

        let canRegisterExpectation = expectation(description: "Can register a SEPA account with Adyen")
        canRegisterExpectation.expectedFulfillmentCount = 1

        let canCreateWithBackendExpectation = expectation(description: "Can create the registered SEPA payment method with the merchant backend")
        canCreateWithBackendExpectation.expectedFulfillmentCount = 1

        let canAuthorizePaymentExpectation = expectation(description: "Can authorize payment for Adyen SEPA payment method")
        canAuthorizePaymentExpectation.expectedFulfillmentCount = 1

        registrationManager.registerSEPAAccount(sepaData: sepa) { result in
            self.registerAndPayWithPaymentMethod(registrationResult: result,
                                                 paymentMethodType: "SEPA",
                                                 pspName: "Adyen",
                                                 canCreateMethodExpectation: canCreateWithBackendExpectation,
                                                 canAuthorizePaymentExpectation: canAuthorizePaymentExpectation)
            canRegisterExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    private func registerAndPayWithPaymentMethod(registrationResult result: RegistrationResult,
                                                 paymentMethodType: String,
                                                 pspName: String,
                                                 canCreateMethodExpectation: XCTestExpectation,
                                                 canAuthorizePaymentExpectation: XCTestExpectation) {
        switch result {
        case let .success(registered):
            guard let alias = registered.alias
            else { XCTFail("Did not receive an alias from registering \(paymentMethodType) account though one was expected"); break }

            switch (registered.extraAliasInfo, paymentMethodType) {
            case (.sepa, "SEPA"):
                self.createPaymentMethodWithBackend(alias: alias,
                                                    paymentMethodType: paymentMethodType,
                                                    canCreateMethodExpectation: canCreateMethodExpectation) {
                    self.authorizePayment(paymentMethod: $0,
                                          canAuthorizePaymentExpectation: canAuthorizePaymentExpectation)
                }
            case (.creditCard, "CC"):
                self.createPaymentMethodWithBackend(alias: alias,
                                                    paymentMethodType: paymentMethodType,
                                                    canCreateMethodExpectation: canCreateMethodExpectation) {
                    self.authorizePayment(paymentMethod: $0,
                                          canAuthorizePaymentExpectation: canAuthorizePaymentExpectation)
                }
            default:
                XCTFail("Got a non-\(paymentMethodType) extra info response when registering \(paymentMethodType) with \(pspName): \(registered.extraAliasInfo)")
            }
        case let .failure(error):
            XCTFail("Error during \(paymentMethodType) \(pspName) registration: \(error)")
        }
    }

    private func createPaymentMethodWithBackend(alias: String,
                                                paymentMethodType: String,
                                                canCreateMethodExpectation: XCTestExpectation,
                                                completion: @escaping (TestMerchantPaymentMethod) -> Void) {
        self.backend.createPaymentMethod(alias: alias, paymentMethodType: paymentMethodType, completion: { merchantRegistration in
            switch merchantRegistration {
            case let .success(registration):
                completion(registration)
            case let .failure(error):
                XCTFail("Could not create payment method with merchant backend: \(error)")
            }

            canCreateMethodExpectation.fulfill()
        })
    }

    private func authorizePayment(paymentMethod: TestMerchantPaymentMethod, canAuthorizePaymentExpectation: XCTestExpectation) {
        let paymentRequest = PaymentRequest(amount: 300,
                                            currency: "EUR",
                                            paymentMethodId: paymentMethod.paymentMethodId,
                                            reason: "Integration Test Payment")

        self.backend.authorizePayment(payment: paymentRequest) { result in
            switch result {
            case let .success(authorization):
                XCTAssertEqual(authorization.amount, paymentRequest.amount)
                XCTAssertEqual(authorization.currency, paymentRequest.currency)
                XCTAssertTrue(authorization.status == "SUCCESS" || authorization.status == "PENDING")
                XCTAssertNotNil(authorization.transactionId)
            case let .failure(error):
                XCTFail("Error during payment authorization: \(error)")
            }

            canAuthorizePaymentExpectation.fulfill()
        }
    }

    private func initializeSDKForAdyen() {
        self.initializeSDK(for: StashAdyen())
    }

    private func initializeSDKForBSPayone() {
        self.initializeSDK(for: StashBSPayone())
    }

    private func initializeSDK(for provider: PaymentServiceProvider) {
        let integration = PaymentProviderIntegration(paymentServiceProvider: provider)
        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-demo.mblb.net/api/v1",
                                               integrations: [integration])
        configuration.loggingEnabled = true
        configuration.useTestMode = true
        Stash.initialize(configuration: configuration)
    }
}
