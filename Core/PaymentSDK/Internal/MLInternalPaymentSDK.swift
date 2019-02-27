//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

class MLInternalPaymentSDK {

    var networkingClient: NetworkClientCore?
    var provider: PaymentServiceProvider!
    var publicToken: String?
    
    static let sharedInstance = MLInternalPaymentSDK()
    
    func setUp(publicToken: String) {
        self.publicToken = publicToken
        
        MLConfigurationBuilder.sharedInstance.setupConfiguration(token: publicToken)
    }
    
    func setUp(publicToken: String, provider: PaymentServiceProvider) {
        self.publicToken = publicToken
        self.provider = provider
        
        MLConfigurationBuilder.sharedInstance.setupConfiguration(token: publicToken)
    }
}

//MARK: Register methods
extension MLInternalPaymentSDK {
    
    func addMethod(paymentMethod: MLPaymentMethod, success: @escaping (String) -> Void, failiure: @escaping (MLError) -> Void) {
        networkingClient?.addMethod(paymentMethod: paymentMethod, success: success, failiure: failiure)
    }

}

//MARK: Payment methods
extension MLInternalPaymentSDK {  
}


