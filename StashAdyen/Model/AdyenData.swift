//
//  AdyenConfigData.swift
//  StashAdyen
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

struct AdyenData: Codable {
    /// The created payment session ID
    let paymentSession: String

    public init?(pspData: PSPExtra) {
        guard let paymentSession = pspData.paymentSession else {
            return nil
        }
        self.paymentSession = paymentSession
    }
}
