//
//  PaymentServiceProviderObjCBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge that allows using payment providers from Objective-C. This should only be used by the modules to create their Objective-C bridges.
@objc(MLPaymentProvider) public final class PaymentProviderBridge: NSObject {
    let paymentProvider: PaymentServiceProvider

    /// Create a new payment provider
    ///
    /// - Parameter paymentProvider: The (Swift) payment provider which this bridge should be based on.
    public init(paymentProvider: PaymentServiceProvider) {
        self.paymentProvider = paymentProvider
    }
}
