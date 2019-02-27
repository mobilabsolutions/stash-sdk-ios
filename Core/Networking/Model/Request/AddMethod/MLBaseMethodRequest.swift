//
//  MLBaseMethodRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 27/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

class MLBaseMethodRequest: Codable {
    
    private(set) var billingData: MLBillingDataReqest!
    private(set) var oneTimePayment = false
    private(set) var customerId: String?
    
    init() { }
    
    init(paymentMethod: MLPaymentMethod) {
        self.billingData = MLBillingDataReqest(billingData: paymentMethod.billingData)
        self.oneTimePayment = paymentMethod.requestData.oneTimePayment
        self.customerId = paymentMethod.requestData.customerId
    }
}
