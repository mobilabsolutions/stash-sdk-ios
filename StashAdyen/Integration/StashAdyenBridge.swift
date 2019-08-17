//
//  StashAdyenBridge.swift
//  StashAdyen
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

/// A class that bridges the Adyen SDK module for usage in Objective-C
@objc(MLStashAdyen) public class StashAdyenBridge: NSObject {
    /// Create a new instance of the Adyen module for communication with the Adyen SDK. This instance can be used to initialize the SDK.
    ///
    /// - Returns: The created module instance
    @objc public static func createModule() -> PaymentProviderBridge {
        return PaymentProviderBridge(paymentProvider: StashAdyen())
    }
}
