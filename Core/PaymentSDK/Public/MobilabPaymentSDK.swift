//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

public typealias RegistrationResult = ((NetworkClientResult<String, MLError>) -> Void)

public class MobilabPaymentSDK {
//    public static func setUp(publicKey: String) {
//        MLInternalPaymentSDK.sharedInstance.setUp(publicKey: publicKey)
//    }

    public static func setUp(provider: PaymentServiceProvider) {
        InternalPaymentSDK.sharedInstance.setUp(provider: provider)
    }

    public static func getRegisterManager() -> RegistrationManager {
        return RegistrationManager()
    }
}
