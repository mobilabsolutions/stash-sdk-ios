//
//  BSPayoneData.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct BSPayoneData: Codable {
    /// The API version of the BSPayone to use
    public let apiVersion: String
    /// The encoding used with the BSPayone
    public let encoding: String
    /// The hash to use with the BSPayone
    public let hash: String
    /// The id of the merchant associated with the key
    public let merchantId: String
    /// The BSPayone portal id
    public let portalId: String
    /// The BSPayone account id
    public let accountId: String
    /// The request to perform when interfacing with the BSPayone
    public let request: String
    /// The response type to use when interfacing with BS Payone
    public let responseType: String
    /// The mode of the payment service provider. Example: "test"
    public let mode: String
}
