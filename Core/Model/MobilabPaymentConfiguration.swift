//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

enum APIEndpoints: String {
    case production = "https://p.mblb.net/api/v1"
    case test = "https://payment-dev.mblb.net/api/v1"
}

public struct MobilabPaymentConfiguration {
    var publicKey: String = ""
    var endpoint: String = ""
    public var loggingEnabled = false

    init() {}

    public init(publicKey: String, endpoint: String) {
        self.publicKey = publicKey
        self.endpoint = endpoint
    }
}
