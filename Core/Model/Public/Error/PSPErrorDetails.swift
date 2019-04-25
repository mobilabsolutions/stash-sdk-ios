//
//  PSPError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PSPErrorDetails: TitleProviding, CustomStringConvertible {
    public let description: String
    public let title: String = "PSP Error"
}

public protocol PSPError {
    var title: String { get }
    var description: String { get }
}

public enum BraintreeError: PSPError, TitleProviding, CustomStringConvertible {
    /// User cancelled PayPal UI
    case userCancelledPayPal
    
    public var description: String {
        switch self {
        case .userCancelledPayPal:
            return ""
        }
    }
    
    public var title: String {
        return "Braintree Error"
    }
}
