//
//  GenericErrorDetails.swift
//  StashCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Details concerning a generic, non-specific error
public struct GenericErrorDetails: TitleProviding, CustomStringConvertible {
    /// A human readable string describing the error
    public let description: String
    /// A human readable title for the error
    public let title: String
    /// A third party error code (e.g. PSP error code)
    public let thirdPartyErrorCode: String?

    /// Create a GenericErrorDetail
    ///
    /// - Parameters:
    ///   - title: The human readable title to use
    ///   - description: A human readable description of the error
    ///   - thirdPartyErrorCode: A third party error code (e.g. PSP error code)
    public init(title: String? = nil, description: String, thirdPartyErrorCode: String? = nil) {
        self.description = description
        self.title = title ?? "Error"
        self.thirdPartyErrorCode = thirdPartyErrorCode
    }

    /// Create a generic error detail from any error
    ///
    /// - Parameter error: The error that should be converted into a StashError
    /// - Returns: The wrapped error
    public static func from(error: Error) -> GenericErrorDetails {
        return GenericErrorDetails(title: "Error", description: error.localizedDescription)
    }
}

extension GenericErrorDetails: Codable {}
