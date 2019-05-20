//
//  PaymentMethodManager.swift
//  Demo
//
//  Created by Rupali Ghate on 16.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentAdyen
import MobilabPaymentBraintree
import MobilabPaymentCore

import Foundation

class PaymentMethodManager {
    static let shared = PaymentMethodManager()

    private var pspIsSetUp = false
    private let testModeEnabled = true

    private init() {}

    func addNewPaymentMethod(viewController: UIViewController, completion: @escaping RegistrationResultCompletion) {
        let paymentManager = PaymentMethodManager.shared
        paymentManager.setupPspForSDK(psp: .adyen)
        paymentManager.configureSDK()

        let configuration = PaymentMethodUIConfiguration()

        MobilabPaymentSDK.configureUI(configuration: configuration)
        MobilabPaymentSDK.getRegistrationManager().registerPaymentMethodUsingUI(on: viewController, completion: completion)
    }

    private func setupPspForSDK(psp _: MobilabPaymentProvider) {
        guard !self.pspIsSetUp
        else { return }

        let provider = MobilabPaymentAdyen()

        MobilabPaymentSDK.registerProvider(provider: provider, forPaymentMethodTypes: .creditCard, .sepa)

        let pspBraintree = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: pspBraintree, forPaymentMethodTypes: .payPal)

        self.pspIsSetUp = true
    }

    private func configureSDK() {
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true
        configuration.useTestMode = self.testModeEnabled

        MobilabPaymentSDK.configure(configuration: configuration)
    }
}
