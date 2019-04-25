//
//  MobilabPaymentError.swift
//  MobilabPayment
//
//  Created by Borna Beakovic on 02/04/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public enum MobilabPaymentError: Error, CustomStringConvertible, TitleProviding, Equatable {
    
    case userActionable(UserActionableErrorDetails)
    case validation(ValidationErrorDetails)
    case configuration(SDKConfigurationError)
    case network(NetworkErrorDetails)
    case psp(PSPError)
    case other(GenericErrorDetails)
    case temporary(TemporaryErrorDetails)

    public var title: String {
        switch self {
        case let .userActionable(details): return details.title
        case let .validation(details): return details.title
        case let .configuration(details): return details.title
        case let .network(details): return details.title
        case let .psp(details): return details.title
        case let .other(details): return details.title
        case let .temporary(details): return details.title
        }
    }

    public var description: String {
        switch self {
        case let .userActionable(details): return details.description
        case let .validation(details): return details.description
        case let .configuration(details): return details.description
        case let .network(details): return details.description
        case let .psp(details): return details.description
        case let .other(details): return details.description
        case let .temporary(details): return details.description
        }
    }
    
    public static func == (lhs: MobilabPaymentError, rhs: MobilabPaymentError) -> Bool {
        return lhs.description == rhs.description
    }
}

public struct MobilabPaymentApiError<S: MobilabPaymentErrorConvertible>: Error, MobilabPaymentErrorConvertible {
    public let error: S

    public func toMobilabPaymentError() -> MobilabPaymentError {
        return self.error.toMobilabPaymentError()
    }
}
