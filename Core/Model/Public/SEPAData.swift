//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// SEPAData contains all data necessary for registering a SEPA account with a payment service provider
public struct SEPAData: RegistrationData {
    /// The BIC (Bank Identifier Code) associated with the SEPA account
    public let bic: String
    /// The IBAN (International Bank Account Number) associated with the SEPA account
    public let iban: String
    /// The billing data to use when registering the SEPA account with a payment service provider
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
