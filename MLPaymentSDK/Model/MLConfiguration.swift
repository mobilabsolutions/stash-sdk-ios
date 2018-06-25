//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

struct MLConfiguration {
    var publicToken: String
    var endpoint: URL
    var provider: PaymentProvider
    
    init(publicToken: String, endpoint: URL, provider: PaymentProvider) {
        self.publicToken = publicToken
        self.endpoint = endpoint
        self.provider = provider
    }
    
}
