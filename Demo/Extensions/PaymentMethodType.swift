//
import Foundation
//  PaymentMethodType.swift
//  Demo
//
//  Created by Rupali Ghate on 04.06.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//
import MobilabPaymentCore

extension PaymentMethodType {
    /// Get the internal payment method type associated to the given payment method type
    var paymentMethodIdentifier: String {
        switch self {
        case .creditCard:
            return "CC"
        case .sepa:
            return "SEPA"
        case .payPal:
            return "PAY_PAL"
        }
    }
}
