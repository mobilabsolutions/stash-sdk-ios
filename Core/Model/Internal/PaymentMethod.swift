//
//  PaymentMethod.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class PaymentMethod {
    let methodData: RegistrationData
    let type: InternalPaymentMethodType

    init(methodData: RegistrationData, type: InternalPaymentMethodType) {
        self.methodData = methodData
        self.type = type
    }

    func toAliasExtra() -> AliasExtra? {
        switch self.type {
        case .creditCard:
            guard let method = methodData as? CreditCardData, let cardMask = method.cardMask
            else { return nil }

            let extra = CreditCardExtra(ccExpiry: "\(method.expiryYear)\(String(format: "%02d", method.expiryMonth))",
                                        ccMask: cardMask, ccType: method.cardType.rawValue)
            return AliasExtra(ccConfig: extra)
        case .sepa:
            guard let method = methodData as? SEPAData
            else { return nil }

            let extra = SepaExtra(iban: method.iban, bic: method.bic,
                                  name: method.billingData.name, email: method.billingData.email,
                                  street: method.billingData.address1, country: method.billingData.country,
                                  zip: method.billingData.zip)
            return AliasExtra(sepaConfig: extra)
        case .payPal:
            guard methodData is PayPalData
            else { return nil }

            let extra = PayPalExtra()
            return AliasExtra(payPalConfig: extra)
        default:
            return nil
        }
    }
}
