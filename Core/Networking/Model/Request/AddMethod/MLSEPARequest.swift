//
//  MLSEPARequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 27/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//


class MLSEPARequest: MLBaseMethodRequest {
    
    private(set) var accountData: MLAccountDataReqest!
    
    //Added cardMask only for backend not to fail, but should not be in this object
    private(set) var cardMask = "no-value"
    
    override init() {
        super.init()
    }
    
    override init(paymentMethod: MLPaymentMethod) {
        super.init(paymentMethod: paymentMethod)
        self.accountData = MLAccountDataReqest(sepaData: paymentMethod.methodData as! MLSEPAData)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

}
