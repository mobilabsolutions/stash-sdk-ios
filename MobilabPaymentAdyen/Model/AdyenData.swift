//
//  AdyenConfigData.swift
//  MobilabPaymentAdyen
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct AdyenData: Codable {
    /// The created payment session ID
    let paymentSession: String
}
