//
//  File.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// Request data sent when registering CreditCard or SEPA
/// This class is not visible outside the SDK
class MLRegisterRequestData {
    
    var cardMask: String
    var type: MLPaymentMethodType
    var oneTimePayment: Bool
    var customerId: String?
    
    init(cardMask: String, type: MLPaymentMethodType, oneTimePayment: Bool, customerId: String?) {
        self.cardMask = cardMask
        self.type = type
        self.oneTimePayment = oneTimePayment
        self.customerId = customerId
    }
}
