//
//  StashError.swift
//  StashCore
//
//  Created by Borna Beakovic on 02/04/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// An error that occurred during payment method creation
public enum StashError: Error, CustomStringConvertible, TitleProviding {
    /// Local data validation failed (e.g. incorrect CVV)
    case validation(ValidationErrorDetails)
    /// An SDK configuration error happened (either locally or with the backend)
    case configuration(SDKConfigurationError)
    /// A network failure happened
    case network(NetworkErrorDetails)
    /// The error cause was not determinable or does not fit into one
    /// of the provided categories
    case other(GenericErrorDetails)
    /// A temporary PSP error happened
    case temporary(TemporaryErrorDetails)
    /// The user cancelled the operation
    case userCancelled

    /// A human-readable title that describes the error
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

    /// A human readable description that gives more information about the error. May also contain an error code.
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

/// An error that occurred in the backend
struct StashAPIError<S: StashErrorConvertible>: Error, StashErrorConvertible {
    let error: S

    func toStashError() -> StashError {
        return self.error.toStashError()
    }
}