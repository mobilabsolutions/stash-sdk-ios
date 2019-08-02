//
//  MobilabBSPayoneBridge.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

/// A bridge that allows usage of the BS Payone module from Objective-C.
@objc(MLMobilabBSPayone) public class MobilabBSPayoneBridge: NSObject {
    /// Create an instance of the BS Payone module. Can be used to initialize the SDK.
    ///
    /// - Returns: The created instance.
    @objc public static func createModule() -> PaymentProviderBridge {
        return PaymentProviderBridge(paymentProvider: MobilabPaymentBSPayone())
    }
}
