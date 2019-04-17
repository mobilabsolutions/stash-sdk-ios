//
//  PaymentMethodProvidable.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

/// A type that can create registration data
public protocol PaymentMethodDataProvider {
    /// A callback to call once the registration data is created
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)? { get set }
    /// A method that is called when an error occurs during payment method creation
    func errorWhileCreatingPaymentMethod(error: MobilabPaymentError)
}
