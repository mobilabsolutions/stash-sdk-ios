//
//  MLConfiguration.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

enum APIEndpoints: String {
    case production = "https://p.mblb.net/api/v1"
    case test = "http://35.201.114.255/api/v1"
}

class MobilabPaymentConfigurationBuilder {
    
    var configuration: MobilabPaymentConfiguration?
    
    static let sharedInstance = MobilabPaymentConfigurationBuilder()
    
    func setupConfiguration(token: String, pspType:String) {
        let arrayOfItems = token.split(separator: "-")
        var endpoint: APIEndpoints?
        if arrayOfItems.count == 3 {
            let mode = arrayOfItems[0]
            if mode == "PD" {
                endpoint = APIEndpoints.test
            } else if mode == "P" {
                endpoint = APIEndpoints.production
            }

            if let end = endpoint {
                configuration = MobilabPaymentConfiguration(publicToken: token, pspType: pspType, endpoint: end)
            }
        }
    }
}

struct MobilabPaymentConfiguration {
    
    var publicToken: String
    var pspType: String
    var endpoint: APIEndpoints
    
    init(publicToken: String, pspType: String, endpoint: APIEndpoints) {
        self.publicToken = publicToken
        self.pspType = pspType
        self.endpoint = endpoint
    }
}
