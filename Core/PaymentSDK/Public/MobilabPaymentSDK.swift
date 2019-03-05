//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

public class MobilabPaymentSDK {

//    public static func setUp(publicKey: String) {
//        MLInternalPaymentSDK.sharedInstance.setUp(publicKey: publicKey)
//    }
    
    public static func setUp(provider: PaymentServiceProvider) {
        InternalPaymentSDK.sharedInstance.setUp(provider: provider)
    }
    
    public static func createRegisterManager(delegate: RegistrationManagerProtocol) -> RegistrationManager {
        return RegistrationManager(delegate: delegate)
    }

}
