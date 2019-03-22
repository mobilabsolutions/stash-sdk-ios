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
    func testPSPRegistersForSupportedPaymentMethodTypes() {
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.configure(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")

        // Fatal error is NOT expected because provider supports selected payment method types
        notExpectFatalError {
            MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard, .sepa)
        }
    }

    func testPSPFailsToRegisterForSupportedPaymentMethodTypes() {
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.configure(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")

        // Fatal error is expected because provider doesn't support selected payment method types
        expectFatalError {
            MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .payPal)
        }
    }

    func testPSPUsedForRegisteringProvidedPaymentMethods() {
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.configure(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")
        MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard)

        let sepaProvider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")
        MobilabPaymentSDK.registerProvider(provider: sepaProvider, forPaymentMethodTypes: .sepa)

        let payPalProvider = MobilabPaymentBraintree(tokenizationKey: "1234567890987654321", urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: payPalProvider, forPaymentMethodTypes: .payPal)

        let providerUsedForCreditCard = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .creditCard)
        let providerUsedForSepa = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .sepa)
        let providerUsedForPayPal = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .payPal)

        XCTAssertEqual(creditCardProvider.pspIdentifier, providerUsedForCreditCard.pspIdentifier)
        XCTAssertEqual(sepaProvider.pspIdentifier, providerUsedForSepa.pspIdentifier)
        XCTAssertEqual(payPalProvider.pspIdentifier, providerUsedForPayPal.pspIdentifier)
    }

    func testPSPUsedForRegisteringNotProvidedPaymentMethods() {
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        MobilabPaymentSDK.configure(configuration: configuration)

        let creditCardProvider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")
        MobilabPaymentSDK.registerProvider(provider: creditCardProvider, forPaymentMethodTypes: .creditCard)

        let payPalProvider = MobilabPaymentBraintree(tokenizationKey: "1234567890987654321", urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: payPalProvider, forPaymentMethodTypes: .payPal)

        let providerUsedForSepa = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: .sepa)
        XCTAssertEqual(creditCardProvider.pspIdentifier, providerUsedForSepa.pspIdentifier, "First registered PSP should be used as default one for all unregistered payment types")
    }
}
