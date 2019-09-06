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
    /// Client encryption key used for credit card data encryption
    let clientEncryptionKey: String

    public init?(pspData: PSPExtra) {
        guard let clientEncryptionKey = pspData.clientEncryptionKey else {
            return nil
        }
        self.clientEncryptionKey = clientEncryptionKey
    }
}
