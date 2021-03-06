//
//  PSPExtra.swift
//  StashCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Information about the used PSP retrieved from Stash payment backend.
/// All fields are optional and will be populated based on 'type' property (PSP).
/// This struct only concerns module development.
public struct PSPExtra: Codable {
    /// The type of payment service provider used.
    public let type: StashPaymentProvider
    /// The mode of the payment service provider. Example: "test"
    public let mode: String?
    /// The id of the merchant associated with the key
    public let merchantId: String?

    // BSPayone Data
    /// The API version of the BSPayone to use
    public let apiVersion: String?
    /// The encoding used with the BSPayone
    public let encoding: String?
    /// The hash to use with the BSPayone
    public let hash: String?
    /// The BSPayone portal id
    public let portalId: String?
    /// The BSPayone account id
    public let accountId: String?
    /// The request to perform when interfacing with the BSPayone
    public let request: String?
    /// The response type to use when interfacing with BS Payone
    public let responseType: String?

    // Braintree Data
    /// Client token used for initializing Braintree SDK
    public let clientToken: String?

    // Adyen Data
    /// Adyen client encryption key used for credit card data encryption
    public let clientEncryptionKey: String?
}
