//
//  AdyenConfigData.swift
//  MobilabPaymentAdyen
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct AdyenData: Codable {
    /// Return URL for Adyen
    let returnUrl: String

    /// The created payment session ID
    let sessionID: String
}
