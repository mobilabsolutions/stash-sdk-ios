//
//  MainTabBarController.swift
//  Demo
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentBSPayone
import MobilabPaymentCore
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        var configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.addProvider(provider: MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"))
    }
}
