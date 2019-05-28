//
//  BraintreeError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public enum BraintreeError {
    /// User cancelled PayPal UI
    case userCancelledPayPal

    func asMobilabPaymentError() -> MobilabPaymentError {
        switch self {
        case .userCancelledPayPal: return .userCancelled
        }
    }
}
