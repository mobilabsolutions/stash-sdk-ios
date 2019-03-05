//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

class InternalPaymentSDK {

    var networkingClient: NetworkClientCore!
    var provider: PaymentServiceProvider!
    //var publicKey: String?
    
    static let sharedInstance = InternalPaymentSDK()
    
//    func setUp(publicKey: String) {
//        self.publicKey = publicKey
//
//        MLConfigurationBuilder.sharedInstance.setupConfiguration(token: publicKey)
//    }
    
    func setUp(provider: PaymentServiceProvider) {
        self.provider = provider
        
        MobilabPaymentConfigurationBuilder.sharedInstance.setupConfiguration(token: provider.publicKey, pspType: provider.pspType)
        networkingClient = NetworkClientCore()
    }
    
    func registrationManager() -> InternalRegistrationManager {
        
        let manager = InternalRegistrationManager(provider: provider, client: networkingClient)
        return manager
    }
}


