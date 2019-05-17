//
//  RegistrationResult.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public typealias RegistrationResult = Result<Registration, MobilabPaymentError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

/// A successful payment method registration
public struct Registration {
    /// The alias with which to access the payment method in the future
    public let alias: String?
    /// The type of payment method that was registered
    public let paymentMethodType: PaymentMethodType
    /// A human readable identifier for the payment method (e.g. IBAN or masked credit card number)
    public let humanReadableIdentifier: String?
}

extension Registration: Codable {}
