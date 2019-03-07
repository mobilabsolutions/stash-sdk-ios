//
//  MLAddCreditCardResponseBS.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLAddCreditCardResponseBS: MLAddCreditCardResponse {
    override init() {
        super.init()
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
