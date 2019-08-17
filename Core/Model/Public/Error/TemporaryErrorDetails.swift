//
//  TemporaryErrorDetails.swift
//  StashCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Details for a temporary error
public struct TemporaryErrorDetails: TitleProviding, CustomStringConvertible {
    /// A title describing the temporary error
    public let title: String
    /// A description explaining the error
    public let description: String
    /// An optional third party error code (e.g. PSP error code)
    public let thirdPartyErrorCode: String?

    /// Create a new temporary error
    ///
    /// - Parameters:
    ///   - title: A human readable title
    ///   - description: A human readable description
    ///   - thirdPartyErrorCode: A third party error code if applicable (e.g. PSP error code)
    public init(title: String? = nil, description: String, thirdPartyErrorCode: String? = nil) {
        self.title = title ?? "Temporary Error"
        self.description = description
        self.thirdPartyErrorCode = thirdPartyErrorCode
    }
}

extension TemporaryErrorDetails: Codable {}
