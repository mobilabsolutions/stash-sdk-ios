//
//  PSPExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

/// Information about the used PSP retrieved from Mobilab payment backend.
/// Solely used for module development.
public struct PSPExtra: Codable {
    public let bsPayone: BSPayoneExtra?
    public let braintree: BraintreeExtra?
    public let adyen: AdyenExtra?
}

public protocol PSPData {}

// Data needed for BSPayone module configuration
public struct BSPayoneExtra: PSPData, Codable {
    #warning("Some of these values will have to be made optional. Update when this has been discussed with BE.")
    /// The API version of the PSP to use
    public let apiVersion: String
    /// The encoding used with the PSP
    public let encoding: String
    /// The hash to use with the PSP (used for BS Payone)
    public let hash: String
    /// The id of the merchant associated with the key
    public let merchantId: String
    /// The PSP portal id
    public let portalId: String
    /// The PSP account id
    public let accountId: String
    /// The request to perform when interfacing with the PSP
    public let request: String
    /// The response type to use when interfacing with some PSPs (especially BS Payone)
    public let responseType: String?
    /// The type of payment service provider used.
    public let type: String
    /// The mode of the payment service provider. Example: "test"
    public let mode: String
}

// Data needed for Braintree module configuration
public struct BraintreeExtra: PSPData, Codable {
    public let clientToken: String
}

// Data needed for Adyen module configuration
public struct AdyenExtra: PSPData, Codable {
    public let apiKey: String
    public let merchantAccount: String
    public let shopperReference: String
    public let returnUrl: String?
}
