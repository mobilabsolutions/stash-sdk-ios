//
//  MLPaymentMethod.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLPaymentMethod {
    let billingData: BillingData
    let methodData: BaseMethodData
    let requestData: RegisterRequestData

    init(billingData: BillingData, methodData: BaseMethodData, requestData: RegisterRequestData) {
        self.billingData = billingData
        self.methodData = methodData
        self.requestData = requestData
    }

    func toAliasExtra() -> AliasExtra? {
        guard self.requestData.type == .creditCard, let method = methodData as? CreditCardData, let email = self.billingData.email
        else { return nil }

        return AliasExtra(ccExpiry: "\(method.expiryYear)\(String(format: "%02d", method.expiryMonth))",
                          ccMask: "", ccType: "CC", email: email, ibanMask: "", paymentMethod: .creditCard)
    }
}
