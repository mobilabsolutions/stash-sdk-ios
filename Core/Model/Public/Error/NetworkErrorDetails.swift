//
//  NetworkErrorDetails.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public enum NetworkErrorDetails: CustomStringConvertible, TitleProviding {
    case requestFailed(code: Int, description: String)
    case responseInvalid

    public var title: String {
        return "Network Error"
    }

    public var description: String {
        switch self {
        case .responseInvalid: return "Got an invalid response"
        case let .requestFailed(code, description): return "\(description) (\(code))"
        }
    }
}

extension NetworkErrorDetails: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NetworkErrorDetailsKey.self)
        switch self {
        case let .requestFailed(code, description):
            try container.encode("REQUEST_FAILED", forKey: .type)
            try container.encode(CodableTwoTuple(first: code, second: description), forKey: .details)
        case .responseInvalid:
            try container.encode("RESPONSE_INVALID", forKey: .type)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NetworkErrorDetailsKey.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "REQUEST_FAILED":
            let details = try container.decode(CodableTwoTuple<Int, String>.self, forKey: .details)
            self = .requestFailed(code: details.first, description: details.second)
        case "RESPONSE_INVALID":
            self = .responseInvalid
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                                                   debugDescription: "Could not decode NetworkErrorDetails for type \(type)")
        }
    }
}

private enum NetworkErrorDetailsKey: CodingKey {
    case type
    case details
}
