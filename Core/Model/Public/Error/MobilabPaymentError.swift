//
//  MobilabPaymentError.swift
//  MobilabPayment
//
//  Created by Borna Beakovic on 02/04/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public enum MobilabPaymentError: Error, CustomStringConvertible, TitleProviding {
    case userActionable(UserActionableErrorDetails)
    case validation(ValidationErrorDetails)
    case configuration(SDKConfigurationError)
    case network(NetworkErrorDetails)
    case other(GenericErrorDetails)
    case temporary(TemporaryErrorDetails)

    public var title: String {
        switch self {
        case let .userActionable(details): return details.title
        case let .validation(details): return details.title
        case let .configuration(details): return details.title
        case let .network(details): return details.title
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
        case let .other(details): return details.description
        case let .temporary(details): return details.description
        }
    }
}

public struct MobilabPaymentApiError<S: MobilabPaymentErrorConvertible>: Error, MobilabPaymentErrorConvertible {
    public let error: S

    public func toMobilabPaymentError() -> MobilabPaymentError {
        return self.error.toMobilabPaymentError()
    }
}

extension MobilabPaymentError: Codable {
    var typeIdentifier: String {
        switch self {
        case .configuration:
            return MobilabPaymentError.configurationTypeIdentifier
        case .network:
            return MobilabPaymentError.networkTypeIdentifier
        case .other:
            return MobilabPaymentError.otherTypeIdentifier
        case .temporary:
            return MobilabPaymentError.temporaryTypeIdentifier
        case .userActionable:
            return MobilabPaymentError.userActionableTypeIdentifier
        case .validation:
            return MobilabPaymentError.validationTypeIdentifier
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MobilabPaymentErrorKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case MobilabPaymentError.configurationTypeIdentifier:
            self = .configuration(try container.decode(SDKConfigurationError.self, forKey: .details))
        case MobilabPaymentError.networkTypeIdentifier:
            self = .network(try container.decode(NetworkErrorDetails.self, forKey: .details))
        case MobilabPaymentError.otherTypeIdentifier:
            self = .other(try container.decode(GenericErrorDetails.self, forKey: .details))
        case MobilabPaymentError.temporaryTypeIdentifier:
            self = .temporary(try container.decode(TemporaryErrorDetails.self, forKey: .details))
        case MobilabPaymentError.userActionableTypeIdentifier:
            self = .userActionable(try container.decode(UserActionableErrorDetails.self, forKey: .details))
        case MobilabPaymentError.validationTypeIdentifier:
            self = .validation(try container.decode(ValidationErrorDetails.self, forKey: .details))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                                                   debugDescription: "Could not decode MobilabPaymentError for type \(type)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MobilabPaymentErrorKeys.self)

        try container.encode(self.typeIdentifier, forKey: .type)

        switch self {
        case let .configuration(details):
            try container.encode(details, forKey: .details)
        case let .network(details):
            try container.encode(details, forKey: .details)
        case let .other(details):
            try container.encode(details, forKey: .details)
        case let .temporary(details):
            try container.encode(details, forKey: .details)
        case let .userActionable(details):
            try container.encode(details, forKey: .details)
        case let .validation(details):
            try container.encode(details, forKey: .details)
        }
    }

    private static var configurationTypeIdentifier: String {
        return "CONFIGURATION"
    }

    private static var networkTypeIdentifier: String {
        return "NETWORK"
    }

    private static var otherTypeIdentifier: String {
        return "OTHER"
    }

    private static var temporaryTypeIdentifier: String {
        return "TEMPORARY"
    }

    private static var userActionableTypeIdentifier: String {
        return "USER_ACTIONABLE"
    }

    private static var validationTypeIdentifier: String {
        return "VALIDATION"
    }
}

private enum MobilabPaymentErrorKeys: CodingKey {
    case type
    case details
}
