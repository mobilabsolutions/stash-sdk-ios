//
//  BraintreeError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

/// Custom Braintree generated errors
///
/// - userCancelledPayPal: The user cancelled the PayPal UI
enum BraintreeError {
    /// User cancelled PayPal UI
    case userCancelledPayPal

    func asMobilabPaymentError() -> MobilabPaymentError {
        switch self {
        case .userCancelledPayPal: return .userCancelled
        }
    }
}
