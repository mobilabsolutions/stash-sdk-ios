//
//  MLPaymentData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLPaymentData {
    
    var amount: Int
    var currency: String
    var merchantId: String
    var reason: String
    var customerId: String?
    
    init(amount: Int, currency: String, merchantId: String, reason: String, customerId: String?) {
        self.amount = amount
        self.currency = currency
        self.merchantId = merchantId
        self.reason = reason
        self.customerId = customerId
    }
    
}
