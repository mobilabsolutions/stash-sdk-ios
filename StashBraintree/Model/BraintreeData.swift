//
//  BraintreeData.swift
//  StashBraintree
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

/// The Braintree PSP data that is returned by the createAlias call
struct BraintreeData {
    /// Client token used for initializing Braintree SDK
    public let clientToken: String

    public init?(pspData: PSPExtra) {
        guard let clientToken = pspData.clientToken else {
            return nil
        }
        self.clientToken = clientToken
    }
}
