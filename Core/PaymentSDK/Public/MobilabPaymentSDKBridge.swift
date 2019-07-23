//
//  MobilabPaymentSDKBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

@objc(MLMobilabPaymentSDK) public class MobilabPaymentSDKBridge: NSObject {
    @objc public static func initialize(configuration: MobilabPaymentConfiguration) {
        MobilabPaymentSDK.initialize(configuration: configuration)
    }

    @objc public static func configureUI(configuration: PaymentMethodUIConfigurationBridge) {
        MobilabPaymentSDK.configureUI(configuration: configuration.configuration)
    }

    @objc public static func getRegistrationManager() -> RegistrationManagerBridge {
        return RegistrationManagerBridge(manager: MobilabPaymentSDK.getRegistrationManager())
    }
}
