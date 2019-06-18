//
//  MerchantPaymentMethod.swift
//  Demo
//
//  Created by Rupali Ghate on 05.06.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct MerchantPaymentMethod {
    var type: String
    var paymentMethodId: String

    init?(with dictionary: [String: Any]) {
        guard let type = dictionary["type"] as? String,
            let paymentMethodId = dictionary["paymentMethodId"] as? String else { return nil }

        self.type = type
        self.paymentMethodId = paymentMethodId
    }
}
