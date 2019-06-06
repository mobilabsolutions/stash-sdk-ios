//
//  MobilabBraintreeBridge.swift
//  MobilabPaymentBraintree
//
//  Created by Borna Beakovic on 20/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

@objc(MLMobilabBraintree) public class MobilabBraintreeBridge: NSObject {
    @objc public static func createModule(urlScheme: String) -> MobilabPaymentSDKBridge.PaymentProviderBridge {
        return MobilabPaymentSDKBridge.PaymentProviderBridge(paymentProvider: MobilabPaymentBraintree(urlScheme: urlScheme))
    }

    @objc public static func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return MobilabPaymentBraintree.handleOpen(url: url, options: options)
    }
}
