//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

public class MobilabPaymentSDK: NSObject {

    public static func setUp(publicToken: String) {
        MLInternalPaymentSDK.sharedInstance.setUp(publicToken: publicToken)
    }
    
    public static func setUp(publicToken: String, provider: PaymentServiceProvider) {
        MLInternalPaymentSDK.sharedInstance.setUp(publicToken: publicToken, provider: provider)
    }
    
    public static func createRegisterManager(delegate: MLRegisterManagerProtocol) -> MLRegisterManager {
        return MLRegisterManager(delegate: delegate)
    }

}
