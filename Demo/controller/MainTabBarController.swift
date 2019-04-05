//
//  MainTabBarController.swift
//  Demo
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentBraintree
import MobilabPaymentBSPayone
import MobilabPaymentCore
import UIKit

let testModeDefaultEnabled = true

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureSDK(testModeEnabled: testModeDefaultEnabled)

        let pspBsPayone = MobilabPaymentBSPayone()
        MobilabPaymentSDK.registerProvider(provider: pspBsPayone, forPaymentMethodTypes: .creditCard, .sepa)

        let pspBraintree = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: pspBraintree, forPaymentMethodTypes: .payPal)
    }

    func didSetTestMode(enabled: Bool) {
        self.configureSDK(testModeEnabled: enabled)
    }

    private func configureSDK(testModeEnabled: Bool) {
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true
        configuration.useTestMode = testModeEnabled

        MobilabPaymentSDK.configure(configuration: configuration)
    }
}
