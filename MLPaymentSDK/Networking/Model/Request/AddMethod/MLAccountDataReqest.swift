//
//  MLCrediCardRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//


class MLAccountDataReqest: Codable {
    
    private(set) var bic = ""
    private(set) var iban = ""
    
    init() {
    }
    
    init(sepaData: MLSEPAData) {
        self.bic = sepaData.bankNumber
        self.iban = sepaData.IBAN
    }

}
