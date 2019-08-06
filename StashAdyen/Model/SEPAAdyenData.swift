//
//  SEPAAdyenData.swift
//  StashAdyen
//
//  Created by Borna Beakovic on 28/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

struct SEPAAdyenData {
    let ownerName: String
    let ibanNumber: String
    let billingData: BillingData?
    let sepaExtra: SEPAExtra
}
