//
//  SEPADataBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge allowing creation of SEPA methods from Objective-C
@objc(MLSEPAData) public class SEPADataBridge: NSObject, SEPADataInitializible {
    let sepaData: SEPAData

    /// Create SEPA data to use for registration. See documentation for `SEPAData` for considerations about the parameters and return values.
    @objc public required init(iban: String, bic: String?, billingData: BillingData) throws {
        self.sepaData = try SEPAData(iban: iban, bic: bic, billingData: billingData)
    }
}
