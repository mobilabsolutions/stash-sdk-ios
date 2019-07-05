//
//  MobilabPaymentError.swift
//  MobilabPayment
//
//  Created by Borna Beakovic on 02/04/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public enum MobilabPaymentError: Error, CustomStringConvertible, TitleProviding {
    case validation(ValidationErrorDetails)
    case configuration(SDKConfigurationError)
    case network(NetworkErrorDetails)
    case other(GenericErrorDetails)
    case temporary(TemporaryErrorDetails)
    case userCancelled

    public var title: String {
        switch self {
        case let .validation(details): return details.title
        case let .configuration(details): return details.title
        case let .network(details): return details.title
        case let .other(details): return details.title
        case let .temporary(details): return details.title
        case .userCancelled: return "User Cancelled"
        }
    }

    public var description: String {
        switch self {
        case let .validation(details): return details.description
        case let .configuration(details): return details.description
        case let .network(details): return details.description
        case let .other(details): return details.description
        case let .temporary(details): return details.description
        case .userCancelled: return "Action cancelled by user"
        }
    }
}

public struct MobilabPaymentApiError<S: MobilabPaymentErrorConvertible>: Error, MobilabPaymentErrorConvertible {
    public let error: S

    public func toMobilabPaymentError() -> MobilabPaymentError {
        return self.error.toMobilabPaymentError()
    }
}
