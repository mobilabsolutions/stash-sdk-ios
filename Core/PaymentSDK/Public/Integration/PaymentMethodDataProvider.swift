//
//  PaymentMethodProvidable.swift
//  StashCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A type that can create registration data
public protocol PaymentMethodDataProvider {
    /// A callback to call once the registration data is created
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)? { get set }
    /// A method that is called when an error occurs during payment method creation
    func errorWhileCreatingPaymentMethod(error: StashError)
}

public extension PaymentMethodDataProvider {
    func errorWhileCreatingPaymentMethod(error _: StashError) {}
}
