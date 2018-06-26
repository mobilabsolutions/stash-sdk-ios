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
        
        if let conf = MLConfigurationBuilder.sharedInstance.setupConfiguration(token: publicToken) {
            switch conf.provider {
            case .BS:
                networkingClient = MLNetworkClientBS(configuration: conf)
            case .HC:
                networkingClient = MLNetworkClientHC(configuration: conf)
            }
           
        } else {
            print("error")
            //MLError(title: "Public token not valid", description: "Public token not valid", code: 100)
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


