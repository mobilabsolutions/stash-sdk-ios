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
    var methodData: BaseMethodData
    var requestData: RegisterRequestData

    
    init(billingData: BillingData, methodData: BaseMethodData, requestData: RegisterRequestData) {
        self.billingData = billingData
        self.methodData = methodData
        self.requestData = requestData
    }
}
