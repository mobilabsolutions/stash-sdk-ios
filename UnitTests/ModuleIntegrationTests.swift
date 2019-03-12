//
//  ModuleIntegrationTests.swift
//  MobilabPaymentTests
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import XCTest

class ModuleIntegrationTests: XCTestCase {
    private var module: PaymentServiceProvider?

    private class TestModule<RegistrationDataType: RegistrationData>: PaymentServiceProvider {
        var pspType: String {
            return "BS_PAYONE"
        }

        var publicKey: String {
            return "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"
        }

        let completionResultToReturn: RegistrationResult
        let registrationRequestCalledExpectation: XCTestExpectation

        init(completionResultToReturn: RegistrationResult, registrationRequestCalledExpectation: XCTestExpectation) {
            self.completionResultToReturn = completionResultToReturn
            self.registrationRequestCalledExpectation = registrationRequestCalledExpectation
        }

        func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping RegistrationResultCompletion) {
            XCTAssertTrue(registrationRequest.registrationData is RegistrationDataType)
            self.registrationRequestCalledExpectation.fulfill()
            completion(self.completionResultToReturn)
        }
    }

    func testHandleRegistrationRequestCalled() {
        let expectation = XCTestExpectation(description: "Handle registration is called")
        let module = TestModule<CreditCardData>(completionResultToReturn: .success("Test alias"),
                                                registrationRequestCalledExpectation: expectation)

        MobilabPaymentSDK.setUp(provider: module)

        self.module = module

        let creditCard = CreditCardData(holderName: "Max Mustermann", cardNumber: "4111111111111111",
                                        cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
        MobilabPaymentSDK.getRegisterManager().registerCreditCard(creditCardData: creditCard) { _ in () }

        wait(for: [expectation], timeout: 5)
    }

    func testModuleFailurePropagatedCorrectly() {
        let calledExpectation = XCTestExpectation(description: "Handle registration is called")
        let resultExpectation = XCTestExpectation(description: "Result is propagated to the SDK user")

        let error = MLError(title: "Test Failure",
                            description: "Sample test failure", code: 123)
        let module = TestModule<CreditCardData>(completionResultToReturn: .failure(error),
                                                registrationRequestCalledExpectation: calledExpectation)

        MobilabPaymentSDK.setUp(provider: module)

        self.module = module

        let creditCard = CreditCardData(holderName: "Max Mustermann", cardNumber: "4111111111111111",
                                        cvv: "123", expiryMonth: 9, expiryYear: 21, billingData: BillingData())
        MobilabPaymentSDK.getRegisterManager().registerCreditCard(creditCardData: creditCard) { result in
            switch result {
            case .success: XCTFail("Should not have returned success when module fails")
            case let .failure(propagatedError): XCTAssertEqual(error.code, propagatedError.code)
            }

            resultExpectation.fulfill()
        }

        wait(for: [calledExpectation, resultExpectation], timeout: 5, enforceOrder: true)
    }
}
