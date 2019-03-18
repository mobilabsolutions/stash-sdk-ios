//
//  RegistrationRequest.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

/// A struct including all information generated from starting credit card registration
/// and having created an alias in the Mobilab backend for it.
/// - Used solely during module development
public struct RegistrationRequest {
    /// The created Mobilab alias for the payment method
    public let aliasId: String
    /// Data about the PSP as fetched from Mobilab backend's configuration
    public let pspData: PSPExtra
    /// User provided registration data: e.g. SEPAData or CreditCardData
    public let registrationData: RegistrationData?

    init(aliasId: String, pspData: PSPExtra, registrationData: RegistrationData? = nil) {
        self.aliasId = aliasId
        self.pspData = pspData
        self.registrationData = registrationData
    }
}

/// Data representing a payment method from the user's view
public protocol RegistrationData {
    /// The billing data to use when registering the payment method
    // var billingData: BillingData { get }
}
