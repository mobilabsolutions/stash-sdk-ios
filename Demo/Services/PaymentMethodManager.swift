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

    private var sdkIsSetUp = false
    private let testModeEnabled = true

    private init() {}

    func addNewPaymentMethod(viewController: UIViewController, completion: @escaping RegistrationResultCompletion) {
        let paymentManager = PaymentMethodManager.shared
        paymentManager.configureSDK()

        let configuration = PaymentMethodUIConfiguration()

        MobilabPaymentSDK.configureUI(configuration: configuration)
        MobilabPaymentSDK.getRegistrationManager().registerPaymentMethodUsingUI(on: viewController, completion: completion)
    }

    private func configureSDK() {
        guard !self.sdkIsSetUp
        else { return }

        let adyen = MobilabPaymentAdyen()
        let adyenIntegration = PaymentProviderIntegration(paymentServiceProvider: adyen)

        let braintree = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        guard let braintreeIntegration = PaymentProviderIntegration(paymentServiceProvider: braintree, paymentMethodTypes: [.payPal])
        else { fatalError("Braintree should support PayPal payment method but does not!") }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [adyenIntegration, braintreeIntegration])
        configuration.loggingEnabled = true
        configuration.useTestMode = self.testModeEnabled

        MobilabPaymentSDK.initialize(configuration: configuration)

        self.sdkIsSetUp = true
    }
}
