//
//  SDKConfigurationTests.swift
//  StashCore
//
//  Created by Borna Beakovic on 22/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import XCTest

@testable import StashBraintree
@testable import StashBSPayone
@testable import StashCore

class SDKConfiguraionTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        SDKResetter.resetStash()
    }

    func testPSPRegistersForSupportedPaymentMethodTypes() {
        let creditCardProvider = StashBSPayone()

        // Fatal error is NOT expected because provider supports selected payment method types
        notExpectFatalError {
            guard let integration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.sepa, .creditCard])
            else { fatalError("This should not happen") }
            let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                   endpoint: "https://payment-demo.mblb.net/api/v1",
                                                   integrations: [integration])
            Stash.initialize(configuration: configuration)
        }
    }

    func testPSPFailsToRegisterForSupportedPaymentMethodTypes() {
        let creditCardProvider = StashBSPayone()
        let integration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.payPal])
        XCTAssertNil(integration, "It should not be possible to create an integration for a payment method type the PSP does not support")
    }

    func testPSPUsedForRegisteringProvidedPaymentMethods() {
        let creditCardProvider = StashBSPayone()
        let sepaProvider = StashBSPayone()
        let payPalProvider = StashBraintree(urlScheme: "com.mobilabsolutions.stash.Demo.paypal")

        guard let creditCardIntegration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.creditCard]),
            let sepaIntegration = PaymentProviderIntegration(paymentServiceProvider: sepaProvider, paymentMethodTypes: [.sepa]),
            let payPalIntegration = PaymentProviderIntegration(paymentServiceProvider: payPalProvider, paymentMethodTypes: [.payPal])
        else { XCTFail("Should be able to create integrations with correct types"); return }

        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-demo.mblb.net/api/v1",
                                               integrations: [creditCardIntegration, sepaIntegration, payPalIntegration])
        Stash.initialize(configuration: configuration)

        let providerUsedForCreditCard = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .creditCard)
        let providerUsedForSepa = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .sepa)
        let providerUsedForPayPal = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .payPal)

        XCTAssertEqual(creditCardProvider.pspIdentifier, providerUsedForCreditCard.pspIdentifier,
                       "Expected CC psp identifier to be \(creditCardProvider.pspIdentifier) but was \(providerUsedForCreditCard.pspIdentifier)")
        XCTAssertEqual(sepaProvider.pspIdentifier, providerUsedForSepa.pspIdentifier,
                       "Expected SEPA psp identifier to be \(sepaProvider.pspIdentifier) but was \(providerUsedForSepa.pspIdentifier)")
        XCTAssertEqual(payPalProvider.pspIdentifier, providerUsedForPayPal.pspIdentifier,
                       "Expected PayPal psp identifier to be \(payPalProvider.pspIdentifier) but was \(providerUsedForPayPal.pspIdentifier)")
    }

    func testCorrectPaymentMethodTypesAreReturned() {
        let creditCardProvider = StashBSPayone()
        let sepaProvider = StashBSPayone()
        let payPalProvider = StashBraintree(urlScheme: "com.mobilabsolutions.stash.Demo.paypal")

        guard let creditCardIntegration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.creditCard]),
            let sepaIntegration = PaymentProviderIntegration(paymentServiceProvider: sepaProvider, paymentMethodTypes: [.sepa]),
            let payPalIntegration = PaymentProviderIntegration(paymentServiceProvider: payPalProvider, paymentMethodTypes: [.payPal])
        else { XCTFail("Should be able to create integrations with correct types"); return }

        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-demo.mblb.net/api/v1",
                                               integrations: [creditCardIntegration, sepaIntegration, payPalIntegration])
        Stash.initialize(configuration: configuration)

        XCTAssertEqual(Stash.getRegistrationManager().availablePaymentMethodTypes, [.creditCard, .sepa, .payPal])
    }

    func testPSPUsedForRegisteringNotProvidedPaymentMethods() {
        let creditCardProvider = StashBSPayone()
        let payPalProvider = StashBraintree(urlScheme: "com.mobilabsolutions.stash.Demo.paypal")

        guard let creditCardIntegration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.creditCard]),
            let payPalIntegration = PaymentProviderIntegration(paymentServiceProvider: payPalProvider, paymentMethodTypes: [.payPal])
        else { XCTFail("Should be able to create integrations with correct types"); return }

        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-demo.mblb.net/api/v1",
                                               integrations: [creditCardIntegration, payPalIntegration])
        Stash.initialize(configuration: configuration)

        expectFatalError {
            _ = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .sepa)
        }
    }
}
