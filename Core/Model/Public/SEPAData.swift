//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

protocol SEPADataInitializible {
    init?(iban: String, bic: String, billingData: BillingData)
}

public struct SEPAData: RegistrationData {
    public let bic: String
    public let iban: String
    public let billingData: BillingData

    public init?(iban: String, bic: String, billingData: BillingData) {
        let cleanedIban = SEPAUtils.cleanedIban(number: iban)
        guard SEPAUtils.isValid(cleanedNumber: cleanedIban)
        else { return nil }

        self.iban = cleanedIban
        self.bic = bic
        self.billingData = billingData
    }
}
