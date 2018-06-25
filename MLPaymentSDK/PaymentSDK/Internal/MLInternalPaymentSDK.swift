//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

class MLInternalPaymentSDK: NSObject {

    var networkingClient: MLNetworkClient?
    var publicToken: String?
    
    static let sharedInstance = MLInternalPaymentSDK()
    
    func setUp(publicToken: String) {
        self.publicToken = publicToken
        
        if publicToken == "BS" {
            let configuration = MLConfiguration(publicToken: "BS", endpoint: URL(string: "https://...")!, provider: PaymentProvider.BS)
            networkingClient = MLNetworkClientBS(configuration: configuration)
        } else if publicToken == "HC" {
            let configuration = MLConfiguration(publicToken: "HC", endpoint: URL(string: "https://...")!, provider: PaymentProvider.HyperCharge)
            networkingClient = MLNetworkClientHC(configuration: configuration)
        }
    }
}

//MARK: Register methods
extension MLInternalPaymentSDK {
    
    func addMethod(paymentMethod: MLPaymentMethod, success: @escaping (String) -> Void, failiure: @escaping (MLError) -> Void) {
        networkingClient?.addMethod(paymentMethod: paymentMethod, success: success, failiure: failiure)
    }
    
    func registerCreditCard() {
        networkingClient?.togetherPay()
    }
}

//MARK: Payment methods
extension MLInternalPaymentSDK {
    
}


