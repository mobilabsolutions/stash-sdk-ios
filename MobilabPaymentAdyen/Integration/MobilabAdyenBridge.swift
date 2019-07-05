//
//  MobilabBSPayoneBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

@objc(MLMobilabAdyen) public class MobilabAdyenBridge: NSObject {
    @objc public static func createModule() -> MobilabPaymentSDKBridge.PaymentProviderBridge {
        return MobilabPaymentSDKBridge.PaymentProviderBridge(paymentProvider: MobilabPaymentAdyen())
    }
}
