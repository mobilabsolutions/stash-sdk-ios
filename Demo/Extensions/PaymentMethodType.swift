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
    /// Get the payment method type associated with each payment method
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
