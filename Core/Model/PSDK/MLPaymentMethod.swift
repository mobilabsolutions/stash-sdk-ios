//
//  MLPaymentMethod.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLPaymentMethod {
    
    var billingData: BillingData
    var methodData: MLBaseMethodData
    var requestData: RegisterRequestData
    
    init(billingData: BillingData, methodData: MLBaseMethodData, requestData: RegisterRequestData) {
        self.billingData = billingData
        self.methodData = methodData
        self.requestData = requestData
    }
}
