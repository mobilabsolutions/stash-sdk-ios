//
//  CreditCardDataBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLCreditCardData) public class CreditCardDataBridge: NSObject, CreditCardDataInitializible {
    let creditCardData: CreditCardData

    @objc public required init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, country: String?, billingData: BillingData) throws {
        self.creditCardData = try CreditCardData(cardNumber: cardNumber,
                                                 cvv: cvv,
                                                 expiryMonth: expiryMonth,
                                                 expiryYear: expiryYear,
                                                 country: country,
                                                 billingData: billingData)
    }
}
