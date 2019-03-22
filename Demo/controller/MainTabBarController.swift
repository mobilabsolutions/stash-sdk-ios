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

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true

        MobilabPaymentSDK.configure(configuration: configuration)

        let pspBsPayone = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")
        MobilabPaymentSDK.registerProvider(provider: pspBsPayone, forPaymentMethodTypes: .creditCard, .sepa)

        let pspBraintree = MobilabPaymentBraintree(tokenizationKey: "1234567890987654321", urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: pspBraintree, forPaymentMethodTypes: .payPal)
    }
}
