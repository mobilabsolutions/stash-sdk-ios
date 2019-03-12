//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public struct CreditCardData: RegistrationData {
    public let holderName: String
    public let cardNumber: String
    public let cardType: String = "V"
    public let cvv: String
    public let expiryMonth: Int
    public let expiryYear: Int
    public let billingData: BillingData
    public let additionalData: [String: String]

    public init(holderName: String, cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, billingData: BillingData,
                additionalData: [String: String] = [:]) {
        self.holderName = holderName
        self.cardNumber = cardNumber
        self.cvv = cvv
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.billingData = billingData
        self.additionalData = additionalData
    }
}
