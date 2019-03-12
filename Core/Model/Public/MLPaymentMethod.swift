//
//  MLPaymentMethod.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLPaymentMethod {
    let methodData: RegistrationData
    let requestData: RegisterRequestData

    init(methodData: RegistrationData, requestData: RegisterRequestData) {
        self.methodData = methodData
        self.requestData = requestData
    }

    func toAliasExtra() -> AliasExtra? {
        switch self.requestData.type {
        case .creditCard:
            guard let method = methodData as? CreditCardData
            else { return nil }

            let extra = CreditCardExtra(ccExpiry: "\(method.expiryYear)\(String(format: "%02d", method.expiryMonth))",
                                        ccMask: requestData.cardMask, ccType: "CC")
            return AliasExtra(ccConfig: extra)
        case .sepa:
            guard let method = methodData as? SEPAData
            else { return nil }

            let extra = SepaExtra(iban: method.iban, bic: method.bic,
                                  name: method.billingData.name, email: method.billingData.email,
                                  street: method.billingData.address1, country: method.billingData.country,
                                  zip: method.billingData.zip)
            return AliasExtra(sepaConfig: extra)
        default:
            return nil
        }
    }
}
