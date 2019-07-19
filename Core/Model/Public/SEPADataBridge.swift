//
//  SEPADataBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLSEPAData) public class SEPADataBridge: NSObject, SEPADataInitializible {
    let sepaData: SEPAData
    
    @objc public required init(iban: String, bic: String?, billingData: BillingData) throws {
        self.sepaData = try SEPAData(iban: iban, bic: bic, billingData: billingData)
    }
}
