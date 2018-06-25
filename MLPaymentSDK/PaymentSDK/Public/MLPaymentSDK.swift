//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

class MLPaymentSDK: NSObject {

    static func setUp(publicToken: String) {
        MLInternalPaymentSDK.sharedInstance.setUp(publicToken: publicToken)
    }
    
    static func createRegisterManager(delegate: MLRegisterManagerProtocol) -> MLRegisterManager {
        return MLRegisterManager(delegate: delegate)
    }
    
    static func createPaymentManager(delegate: MLPaymentManagerProtocol) -> MLPaymentManager {
        return MLPaymentManager(delegate: delegate)
    }
}
