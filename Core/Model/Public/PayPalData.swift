//
//  PayPalData.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 14/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PayPalPlaceholderData: RegistrationData {}

public struct PayPalData: RegistrationData {
    public let nonce: String
    public let deviceData: String

    public init(nonce: String, deviceData: String) {
        self.nonce = nonce
        self.deviceData = deviceData
    }
}
