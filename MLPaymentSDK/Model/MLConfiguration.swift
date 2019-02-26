//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

enum MLAPIEndpoints: String {
    case production = "https://p.mblb.net/api/v1"
    case test = "https://pd.mblb.net/api/v1"
}

class MLConfigurationBuilder {
    
    var configuration: MLConfiguration?
    
    static let sharedInstance = MLConfigurationBuilder()
    
    func setupConfiguration(token: String) {
        let arrayOfItems = token.split(separator: "-")
        var endpoint: MLAPIEndpoints?
        var provider: MLPaymentProvider?
        if arrayOfItems.count == 3 {
            let mode = arrayOfItems[0]
            if mode == "PD" {
                endpoint = MLAPIEndpoints.test
            } else if mode == "P" {
                endpoint = MLAPIEndpoints.production
            }
            provider = MLPaymentProvider(rawValue: String(arrayOfItems[1]))
            if let end = endpoint, let prov = provider {
                configuration = MLConfiguration(publicToken: token, endpoint: end, provider: prov)
            }
        }
    }
}

struct MLConfiguration {
    
    var publicToken: String
    var endpoint: MLAPIEndpoints
    var provider: MLPaymentProvider
    
    init(publicToken: String, endpoint: MLAPIEndpoints, provider: MLPaymentProvider) {
        self.publicToken = publicToken
        self.endpoint = endpoint
        self.provider = provider
    }
}
