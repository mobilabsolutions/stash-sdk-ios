//
//  MobilabBSPayoneBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

@objc(MLMobilabBSPayone) public class MobilabBSPayoneBridge: NSObject {
    @objc public static func createModule() -> MobilabPaymentSDKBridge.PaymentProviderBridge {
        return MobilabPaymentSDKBridge.PaymentProviderBridge(paymentProvider: MobilabPaymentBSPayone())
    }
}
