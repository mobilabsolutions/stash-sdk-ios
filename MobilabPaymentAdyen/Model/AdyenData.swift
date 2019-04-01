//
//  AdyenConfigData.swift
//  MobilabPaymentAdyen
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public struct AdyenData: Codable {
    /// Api key used for Adyen authentification
    public let apiKey: String
    /// Adyen merchant account
    public let merchantAccount: String
    /// Adyen shopper reference
    public let shopperReference: String
    /// Return URL for Adyen
    public let returnUrl: String
}
