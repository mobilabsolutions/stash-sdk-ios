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
