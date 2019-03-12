//
//  RegistrationRequest.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct RegistrationRequest {
    public let aliasId: String
    public let pspData: PSPExtra
    public let registrationData: RegistrationData?

    init(aliasId: String, pspData: PSPExtra, registrationData: RegistrationData? = nil) {
        self.aliasId = aliasId
        self.pspData = pspData
        self.registrationData = registrationData
    }
}

public protocol RegistrationData {
    var billingData: BillingData { get }
}
