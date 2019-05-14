//
//  SEPAAdyenData.swift
//  MobilabPaymentAdyen
//
//  Created by Borna Beakovic on 28/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct SEPAAdyenData {
    let ownerName: String
    let ibanNumber: String
    let billingData: BillingData?
    let sepaExtra: SEPAExtra
}
