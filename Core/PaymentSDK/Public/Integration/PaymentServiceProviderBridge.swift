//
//  PaymentServiceProviderObjCBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLPaymentProvider) public final class PaymentProviderBridge: NSObject {
    let paymentProvider: PaymentServiceProvider
    
    public init(paymentProvider: PaymentServiceProvider) {
        self.paymentProvider = paymentProvider
    }
}
