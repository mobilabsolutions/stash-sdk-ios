//
//  MLCreditCardRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 27/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//


class MLCreditCardRequest: MLBaseMethodRequest {
    
    private(set) var cardMask = ""
    
    override init() {
        super.init()
    }
    
    override init(paymentMethod: MLPaymentMethod) {
        super.init(paymentMethod: paymentMethod)
        self.cardMask = paymentMethod.requestData.cardMask
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
