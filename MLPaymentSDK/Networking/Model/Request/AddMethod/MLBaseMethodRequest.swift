//
//  MLBaseMethodRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 27/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLBaseMethodRequest: Mappable {
    
    private(set) var billingData: MLBillingDataReqest!
    private(set) var oneTimePayment = false
    private(set) var customerId: String?
    
    init() { }
    
    init(paymentMethod: MLPaymentMethod) {
        self.billingData = MLBillingDataReqest(billingData: paymentMethod.billingData)
        self.oneTimePayment = paymentMethod.requestData.oneTimePayment
        self.customerId = paymentMethod.requestData.customerId
    }
    
    required convenience init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        billingData <- map["billingData"]
        oneTimePayment <- map["oneTimePayment"]
        customerId <- map["customerId"]
    }
}
