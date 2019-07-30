//
//  BSPayoneData.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

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

    public init?(pspData: PSPExtra) {
        guard
            let apiVersion = pspData.apiVersion,
            let encoding = pspData.encoding,
            let hash = pspData.hash,
            let merchantId = pspData.merchantId,
            let portalId = pspData.portalId,
            let accountId = pspData.accountId,
            let request = pspData.request,
            let responseType = pspData.responseType,
            let mode = pspData.mode else {
            return nil
        }
        self.apiVersion = apiVersion
        self.encoding = encoding
        self.hash = hash
        self.merchantId = merchantId
        self.portalId = portalId
        self.accountId = accountId
        self.request = request
        self.responseType = responseType
        self.mode = mode
    }
}
