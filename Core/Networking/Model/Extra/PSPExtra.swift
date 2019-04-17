//
//  PSPExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

/// Information about the used PSP retrieved from Mobilab payment backend.
/// All fields are optional and will be populated based on 'type' property (PSP)
public struct PSPExtra: Codable {
    /// The type of payment service provider used.
    public let type: MobilabPaymentProvider

    // BSPayone Data
    /// The API version of the BSPayone to use
    public let apiVersion: String?
    /// The encoding used with the BSPayone
    public let encoding: String?
    /// The hash to use with the BSPayone
    public let hash: String?
    /// The id of the merchant associated with the key
    public let merchantId: String?
    /// The BSPayone portal id
    public let portalId: String?
    /// The BSPayone account id
    public let accountId: String?
    /// The request to perform when interfacing with the BSPayone
    public let request: String?
    /// The response type to use when interfacing with BS Payone
    public let responseType: String?
    /// The mode of the payment service provider. Example: "test"
    public let mode: String?

    // Braintree Data
    /// Client token used for initializing Braintree SDK
    public let clientToken: String?

    // Adyen Data
    /// Api key used for Adyen authentification
    public let apiKey: String?
    /// Adyen merhcant account
    public let merchantAccount: String?
    /// Adyen shopper reference
    public let shopperReference: String?
    /// Return URL for Adyen
    public let returnUrl: String?

    public func toPSPData<T: Decodable>(type: T.Type) throws -> T {
        do {
            let encodedData = try JSONEncoder().encode(self)
            return try JSONDecoder().decode(type, from: encodedData)
        } catch {
            throw MobilabPaymentError.configuration(.pspInvalidConfiguration)
        }
    }
}
