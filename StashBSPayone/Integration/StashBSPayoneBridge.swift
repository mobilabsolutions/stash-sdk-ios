//
//  StashBSPayoneBridge.swift
//  StashBSPayone
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

/// A bridge that allows usage of the BS Payone module from Objective-C.
@objc(MLStashBSPayone) public class StashBSPayoneBridge: NSObject {
    /// Create an instance of the BS Payone module. Can be used to initialize the SDK.
    ///
    /// - Returns: The created instance.
    @objc public static func createModule() -> PaymentProviderBridge {
        return PaymentProviderBridge(paymentProvider: StashBSPayone())
    }
}
