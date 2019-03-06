//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public class CreditCardData: MLBaseMethodData, Codable {
    var holderName: String
    var cardNumber: String
    var CVV: String
    var expiryMonth: Int
    var expiryYear: Int

    public init(holderName: String, cardNumber: String, CVV: String, expiryMonth: Int, expiryYear: Int) {
        self.holderName = holderName
        self.cardNumber = cardNumber
        self.CVV = CVV
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
}
