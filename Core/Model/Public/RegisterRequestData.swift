//
//  File.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// Request data sent when registering CreditCard or SEPA
/// This class is not visible outside the SDK
struct RegisterRequestData: Codable {
    var cardMask: String
    var type: PaymentMethodType

    init(cardMask: String, type: PaymentMethodType) {
        self.cardMask = cardMask
        self.type = type
    }
}
