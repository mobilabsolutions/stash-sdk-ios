//
//  PaymentMethod.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

struct PaymentMethod {
    let type: PaymentMethodType
    let alias: String?
    let humanReadableIdentifier: String?
}
