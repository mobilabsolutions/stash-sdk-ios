//
//  SDKConfigurationTests.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 22/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import XCTest

@testable import MobilabPaymentBraintree
@testable import MobilabPaymentBSPayone
@testable import MobilabPaymentCore

class SDKConfiguraionTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        SDKResetter.resetMobilabSDK()
    }

    func testPSPRegistersForSupportedPaymentMethodTypes() {
        let creditCardProvider = MobilabPaymentBSPayone()

        // Fatal error is NOT expected because provider supports selected payment method types
        notExpectFatalError {
            guard let integration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.sepa, .creditCard])
            else { fatalError("This should not happen") }
            let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                            endpoint: "https://payment-dev.mblb.net/api/v1",
                                                            integrations: [integration])
            MobilabPaymentSDK.initialize(configuration: configuration)
        }
    }

    func testPSPFailsToRegisterForSupportedPaymentMethodTypes() {
        let creditCardProvider = MobilabPaymentBSPayone()
        let integration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.payPal])
        XCTAssertNil(integration, "It should not be possible to create an integration for a payment method type the PSP does not support")
    }

    func testPSPUsedForRegisteringProvidedPaymentMethods() {
        let creditCardProvider = MobilabPaymentBSPayone()
        let sepaProvider = MobilabPaymentBSPayone()
        let payPalProvider = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")

        guard let creditCardIntegration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.creditCard]),
            let sepaIntegration = PaymentProviderIntegration(paymentServiceProvider: sepaProvider, paymentMethodTypes: [.sepa]),
            let payPalIntegration = PaymentProviderIntegration(paymentServiceProvider: payPalProvider, paymentMethodTypes: [.payPal])
        else { XCTFail("Should be able to create integrations with correct types"); return }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [creditCardIntegration, sepaIntegration, payPalIntegration])
        MobilabPaymentSDK.initialize(configuration: configuration)

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
        let creditCardProvider = MobilabPaymentBSPayone()
        let sepaProvider = MobilabPaymentBSPayone()
        let payPalProvider = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")

        guard let creditCardIntegration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.creditCard]),
            let sepaIntegration = PaymentProviderIntegration(paymentServiceProvider: sepaProvider, paymentMethodTypes: [.sepa]),
            let payPalIntegration = PaymentProviderIntegration(paymentServiceProvider: payPalProvider, paymentMethodTypes: [.payPal])
        else { XCTFail("Should be able to create integrations with correct types"); return }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [creditCardIntegration, sepaIntegration, payPalIntegration])
        MobilabPaymentSDK.initialize(configuration: configuration)

        XCTAssertEqual(MobilabPaymentSDK.getRegistrationManager().availablePaymentMethodTypes, [.creditCard, .sepa, .payPal])
    }

    func testPSPUsedForRegisteringNotProvidedPaymentMethods() {
        let creditCardProvider = MobilabPaymentBSPayone()
        let payPalProvider = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")

        guard let creditCardIntegration = PaymentProviderIntegration(paymentServiceProvider: creditCardProvider, paymentMethodTypes: [.creditCard]),
            let payPalIntegration = PaymentProviderIntegration(paymentServiceProvider: payPalProvider, paymentMethodTypes: [.payPal])
        else { XCTFail("Should be able to create integrations with correct types"); return }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [creditCardIntegration, payPalIntegration])
        MobilabPaymentSDK.initialize(configuration: configuration)

        expectFatalError {
            _ = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .sepa)
        }
    }
}
