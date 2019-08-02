//
//  PayPalData.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 14/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Placeholder data provided when starting PayPal registration
public struct PayPalPlaceholderData: RegistrationData {
    /// Billing data that should be used for the registration
    public let billingData: BillingData?

    /// Create new PayPal placeholder data
    ///
    /// - Parameter billingData: The billing data that should be considered
    public init(billingData: BillingData?) {
        self.billingData = billingData
    }

    public var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo {
        let extra = PaymentMethodAlias.PayPalExtraInfo(email: nil)
        return .payPal(extra)
    }
}

/// PayPal payment method information
public struct PayPalData: RegistrationData {
    /// The nonce as provided by the SDK
    public let nonce: String
    /// Device data as provided by the SDK
    public let deviceData: String
    /// The user's email address as provided by the PayPal SDK
    public let email: String?

    /// Create a new PayPalData instance using all necessary information
    ///
    /// - Parameters:
    ///   - nonce: The payment method nonce
    ///   - deviceData: The device data
    ///   - email: The user's email address
    public init(nonce: String, deviceData: String, email: String?) {
        self.nonce = nonce
        self.deviceData = deviceData
        self.email = email
    }

    /// Create associated extra alias info from this
    public var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo {
        let extra = PaymentMethodAlias.PayPalExtraInfo(email: self.email)
        return .payPal(extra)
    }
}
