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
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.initialize(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone()

        // Fatal error is NOT expected because provider supports selected payment method types
        notExpectFatalError {
            MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard, .sepa)
        }
    }

    func testPSPFailsToRegisterForSupportedPaymentMethodTypes() {
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.initialize(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone()

        // Fatal error is expected because provider doesn't support selected payment method types
        expectFatalError {
            MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .payPal)
        }
    }

    func testPSPUsedForRegisteringProvidedPaymentMethods() {
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.initialize(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone()
        MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard)

        let sepaProvider = MobilabPaymentBSPayone()
        MobilabPaymentSDK.registerProvider(provider: sepaProvider, forPaymentMethodTypes: .sepa)

        let payPalProvider = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: payPalProvider, forPaymentMethodTypes: .payPal)

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
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.initialize(configuration: configuration)

        let registrationManager = MobilabPaymentSDK.getRegistrationManager()

        let creditCardProvider = MobilabPaymentBSPayone()
        MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard)

        XCTAssertEqual(registrationManager.availablePaymentMethodTypes, [.creditCard])

        let sepaProvider = MobilabPaymentBSPayone()
        MobilabPaymentSDK.registerProvider(provider: sepaProvider, forPaymentMethodTypes: .sepa)

        XCTAssertEqual(registrationManager.availablePaymentMethodTypes, [.creditCard, .sepa])

        let payPalProvider = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: payPalProvider, forPaymentMethodTypes: .payPal)

        XCTAssertEqual(registrationManager.availablePaymentMethodTypes, [.creditCard, .sepa, .payPal])
    }

    func testPSPUsedForRegisteringNotProvidedPaymentMethods() {
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.initialize(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone()
        MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard)

        let payPalProvider = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: payPalProvider, forPaymentMethodTypes: .payPal)

        let providerUsedForSepa = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .sepa)
        XCTAssertEqual(creditCardProvider.pspIdentifier, providerUsedForSepa.pspIdentifier, "First registered PSP should be used as default one for all unregistered payment types")
    }
}
