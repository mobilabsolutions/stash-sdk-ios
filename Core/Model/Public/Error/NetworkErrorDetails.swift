//
//  NetworkErrorDetails.swift
//  StashCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Details for a network error
public enum NetworkErrorDetails: CustomStringConvertible, TitleProviding {
    /// The network request failed
    case requestFailed(code: Int, description: String)
    /// The retrieved response was invalid
    case responseInvalid

    /// A title detailing this was a network error
    public var title: String {
        return "Network Error"
    }

    /// A description for the error
    public var description: String {
        switch self {
        case .responseInvalid: return "Got an invalid response"
        case let .requestFailed(code, description): return "\(description) (\(code))"
        }
    }
}
