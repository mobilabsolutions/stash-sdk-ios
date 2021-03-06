//
//  RegistrationRequest.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// A struct including all information generated from starting payment method registration
/// and having created an alias in the Stash backend for it.
/// - Used solely during module development
public struct RegistrationRequest {
    /// The created Stash alias for the payment method
    public let aliasId: String
    /// Data about the PSP as fetched from Stash backend's configuration
    public let pspData: PSPExtra
    /// User provided registration data: e.g. SEPAData/CreditCardData/PayPalData
    public let registrationData: RegistrationData?
    /// View controller which should be used as presenting view for UI related events in module
    public let viewController: UIViewController?

    init(aliasId: String, pspData: PSPExtra, registrationData: RegistrationData? = nil, viewController: UIViewController? = nil) {
        self.aliasId = aliasId
        self.pspData = pspData
        self.registrationData = registrationData
        self.viewController = viewController
    }
}

/// Data representing a payment method from the user's view
public protocol RegistrationData {
    /// Payment method information that may be provided to application code
    var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo { get }
}
