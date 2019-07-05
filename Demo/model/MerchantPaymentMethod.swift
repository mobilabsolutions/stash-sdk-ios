//
//  MerchantPaymentMethod.swift
//  Demo
//
//  Created by Rupali Ghate on 05.06.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Contains payment method details received from merchant backend API.

struct MerchantPaymentMethod {
    /// Payment method type (CC, SEPA, PayPal)
    var type: String
    /// Unique ID received from merchant backend. Used for payment authorization.
    var paymentMethodId: String

    init?(with dictionary: [String: Any]) {
        guard let type = dictionary["type"] as? String,
            let paymentMethodId = dictionary["paymentMethodId"] as? String else { return nil }

        self.type = type
        self.paymentMethodId = paymentMethodId
    }
}
