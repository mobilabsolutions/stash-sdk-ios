//
//  BraintreeIntegrationTests.swift
//  StashTests
//
//  Created by Biju Parvathy on 09.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import OHHTTPStubs
@testable import StashBraintree
@testable import StashCore
import XCTest

class BraintreeIntegrationTests: XCTestCase {
    private var provider: PaymentServiceProvider?

    override func setUp() {
        super.setUp()
        OHHTTPStubs.removeAllStubs()
        SDKResetter.resetStash()

        let provider = StashBraintree(urlScheme: "com.your-company.Your-App.mobilab")
        self.provider = provider
        let configuration = StashConfiguration(publishableKey: "mobilabios-3FkSmKQ0sUmzDqxciqRF",
                                               endpoint: "https://payment-dev.mblb.net/api/v1",
                                               integrations: [PaymentProviderIntegration(paymentServiceProvider: provider)])
        configuration.loggingLevel = .normal
        configuration.useTestMode = true
        Stash.initialize(configuration: configuration)
    }

    override func tearDown() {
        super.tearDown()
        SDKResetter.resetStash()
        OHHTTPStubs.removeAllStubs()
    }

    func testCreditCard() throws {
        let expectation = self.expectation(description: "Registering credit card succeeds")
        let billingData = BillingData(email: "mirza@miki.com",
                                      name: SimpleNameProvider(firstName: "Holder",
                                                               lastName: "Name"))
        let creditCardData = try CreditCardData(cardNumber: "4111 1111 1111 1111",
                                                cvv: "123",
                                                expiryMonth: 10,
                                                expiryYear: 20,
                                                country: "DE",
                                                billingData: billingData)

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

    func testHasCorrectPaymentMethodUITypes() {
        let expected: Set = [PaymentMethodType.creditCard, PaymentMethodType.payPal]

        guard let supported = provider?.supportedPaymentMethodTypeUserInterfaces
        else { XCTFail("Could not get supported payment method types for UI from Braintree provider"); return }

        XCTAssertEqual(expected, Set(supported), "Braintree should allow UI payment methods: \(expected) but allows: \(supported)")
    }
}
