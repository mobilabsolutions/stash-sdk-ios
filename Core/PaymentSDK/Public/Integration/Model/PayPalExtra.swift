//
//  PayPalExtra.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PayPalExtra: Codable {
    public let deviceData: String
    public let nonce: String

    public init(nonce: String, deviceData: String) {
        self.nonce = nonce
        self.deviceData = deviceData
    }
}
