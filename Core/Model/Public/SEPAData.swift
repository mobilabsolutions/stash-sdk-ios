//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public struct SEPAData: RegistrationData {
    public let bic: String
    public let iban: String
    public let billingData: BillingData

    public init(iban: String, bic: String, billingData: BillingData) {
        self.iban = iban
        self.bic = bic
        self.billingData = billingData
    }
}
