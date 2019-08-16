//
//  PaymentMethod.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

class PaymentMethod: Codable {
    /// CreditCard, sepa and payPal
    var type: PaymentMethodType
    var alias: String
    var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo
    /// Formatted string constructed using extra info of respective payment method
    var humanReadableIdentifier: String
    /// User ID associated with payment method
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
