//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLSEPAData: MLBaseMethodData {
    
    var bankNumber: String
    var IBAN: String
    
    init(bankNumber: String, IBAN: String) {
        self.bankNumber = bankNumber
        self.IBAN = IBAN
    }
}
