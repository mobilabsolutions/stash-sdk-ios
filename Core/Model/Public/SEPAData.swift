//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

protocol SEPADataInitializible {
    init(iban: String, bic: String, billingData: BillingData) throws
}

public struct SEPAData: RegistrationData, SEPADataInitializible {
    public let bic: String
    public let iban: String
    public let billingData: BillingData

    public init(iban: String, bic: String, billingData: BillingData) throws {
        let cleanedIban = SEPAUtils.cleanedIban(number: iban)
        guard SEPAUtils.isValid(cleanedNumber: cleanedIban)
        else { throw MLError(title: "IBAN is not valid", description: "The provided IBAN is invalid", code: 106) }

        self.iban = cleanedIban
        self.bic = bic
        self.billingData = billingData
    }
}
