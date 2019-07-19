//
//  PaymentMethodTypeBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLPaymentMethodType) public enum PaymentMethodTypeBridge: Int {
    case none = 0
    case creditCard
    case payPal
    case sepa
    
    public var paymentMethodType: PaymentMethodType? {
        switch self {
        case .none: return nil
        case .creditCard: return .creditCard
        case .payPal: return .payPal
        case .sepa: return .sepa
        }
    }
}
