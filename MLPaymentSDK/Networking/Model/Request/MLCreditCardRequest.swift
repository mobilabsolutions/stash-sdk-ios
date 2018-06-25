//
//  MLCrediCardRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLCreditCardRequest: Mappable {
    
    private(set) var cardMask = ""
    private(set) var billingData: MLBillingDataReqest!
    private(set) var oneTime = false
    private(set) var customerId: String?
    
    init() { }
    
    init(paymentMethod: MLPaymentMethod) {
        self.cardMask = paymentMethod.requestData.cardMask
        self.billingData = MLBillingDataReqest(billingData: paymentMethod.billingData)
        self.oneTime = paymentMethod.requestData.oneTime
        self.customerId = paymentMethod.requestData.customerId
    }
    
    required convenience init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        cardMask <- map["cardMask"]
        billingData <- map["billingData"]
        oneTime <- map["oneTime"]
        customerId <- map["customerId"]
    }
}
