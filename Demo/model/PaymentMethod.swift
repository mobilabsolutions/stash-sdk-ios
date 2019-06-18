//
//  PaymentMethod.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class PaymentMethod: Codable {
    var type: PaymentMethodType
    var alias: String
    var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo
    var humanReadableIdentifier: String
    var userId: String
    var paymentMethodId: String?

    init(type: PaymentMethodType, alias: String, extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo, userId: String, paymentMethodId: String?) {
        self.type = type
        self.alias = alias
        self.extraAliasInfo = extraAliasInfo
        self.humanReadableIdentifier = extraAliasInfo.formatToReadableDetails()
        self.userId = userId
        self.paymentMethodId = paymentMethodId
    }
}
