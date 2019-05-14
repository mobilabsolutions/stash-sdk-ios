//
//  PaymentMethod.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class PaymentMethod {
    let methodData: RegistrationData
    let type: InternalPaymentMethodType

    init(methodData: RegistrationData, type: InternalPaymentMethodType) {
        self.methodData = methodData
        self.type = type
    }
}
