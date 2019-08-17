//
//  PayPalExtra.swift
//  StashCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A model that contains all extra information that should be
/// propagated to the payment SDK backend when registering a PayPal method.
/// This will and should not be used by clients directly but only by
/// the core SDK and modules.
public struct PayPalExtra: Codable {
    /// The identifying data for the current device. Used for anti-fraud protection by PayPal
    public let deviceData: String
    /// The PayPal nonce which addresses the payment method with PayPal
    public let nonce: String

    public init(nonce: String, deviceData: String) {
        self.nonce = nonce
        self.deviceData = deviceData
    }
}
