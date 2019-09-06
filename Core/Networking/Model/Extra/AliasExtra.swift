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
    let channel = "iOS"

    public init(ccConfig: CreditCardExtra, billingData: BillingData) {
        self.paymentMethod = .creditCard
        self.ccConfig = ccConfig
        self.sepaConfig = nil
        self.payPalConfig = nil
        self.personalData = PersonalData(billingData: billingData)
    }

    public init(sepaConfig: SEPAExtra, billingData: BillingData) {
        self.paymentMethod = .sepa
        self.sepaConfig = sepaConfig
        self.ccConfig = nil
        self.payPalConfig = nil
        self.personalData = PersonalData(billingData: billingData)
    }

    public init(payPalConfig: PayPalExtra, billingData: BillingData) {
        self.paymentMethod = .payPal
        self.payPalConfig = payPalConfig
        self.ccConfig = nil
        self.sepaConfig = nil
        self.personalData = PersonalData(billingData: billingData)
    }
}

extension AliasExtra: Codable {}
