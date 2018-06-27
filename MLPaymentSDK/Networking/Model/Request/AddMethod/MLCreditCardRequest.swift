//
//  MLCreditCardRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 27/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLCreditCardRequest: MLBaseMethodRequest {
    
    private(set) var cardMask = ""
    
    override init() {
        super.init()
    }
    
    override init(paymentMethod: MLPaymentMethod) {
        super.init(paymentMethod: paymentMethod)
        self.cardMask = paymentMethod.requestData.cardMask
    }
    
    required convenience init(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        cardMask <- map["cardMask"]
    }
}
