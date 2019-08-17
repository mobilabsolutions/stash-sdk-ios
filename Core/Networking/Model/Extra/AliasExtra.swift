//
//  AliasExtra.swift
//  StashCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public struct AliasExtra {
    let ccConfig: CreditCardExtra?
    let sepaConfig: SEPAExtra?
    let payPalConfig: PayPalExtra?
    let personalData: PersonalData?

    let paymentMethod: InternalPaymentMethodType
    let payload: String?

    public init(ccConfig: CreditCardExtra, billingData: BillingData, payload: String? = nil) {
        self.paymentMethod = .creditCard
        self.ccConfig = ccConfig
        self.sepaConfig = nil
        self.payPalConfig = nil
        self.personalData = PersonalData(billingData: billingData)
        self.payload = payload
    }

    public init(sepaConfig: SEPAExtra, billingData: BillingData, payload: String? = nil) {
        self.paymentMethod = .sepa
        self.sepaConfig = sepaConfig
        self.ccConfig = nil
        self.payPalConfig = nil
        self.personalData = PersonalData(billingData: billingData)
        self.payload = payload
    }

    public init(payPalConfig: PayPalExtra, billingData: BillingData, payload: String? = nil) {
        self.paymentMethod = .payPal
        self.payPalConfig = payPalConfig
        self.ccConfig = nil
        self.sepaConfig = nil
        self.personalData = PersonalData(billingData: billingData)
        self.payload = payload
    }
}

extension AliasExtra: Codable {}
