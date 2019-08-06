//
//  CreditCardBSPayoneData.swift
//  StashBSPayone
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

struct CreditCardBSPayoneData {
    let cardPan: String
    let cardType: String
    let cardExpireDate: String
    let cardCVC2: String
    let billingData: BillingData
}
