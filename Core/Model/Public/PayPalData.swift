//
//  PayPalData.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 14/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PayPalPlaceholderData: RegistrationData {
    public let billingData: BillingData?

    public init(billingData: BillingData?) {
        self.billingData = billingData
    }

    public var humanReadableId: String? {
        return nil
    }
}

public struct PayPalData: RegistrationData {
    public let nonce: String
    public let deviceData: String
    public let email: String?

    public init(nonce: String, deviceData: String, email: String?) {
        self.nonce = nonce
        self.deviceData = deviceData
        self.email = email
    }

    public var humanReadableId: String? {
        return self.email
    }
}
