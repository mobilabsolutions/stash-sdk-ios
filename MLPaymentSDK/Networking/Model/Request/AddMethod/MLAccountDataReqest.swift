//
//  MLCrediCardRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLAccountDataReqest: Mappable {
    
    private(set) var bic = ""
    private(set) var iban = ""
    
    init() {
    }
    
    init(sepaData: MLSEPAData) {
        self.bic = sepaData.bankNumber
        self.iban = sepaData.IBAN
    }
    
    required convenience init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        bic <- map["bic"]
        iban <- map["iban"]
    }
}
