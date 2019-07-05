//
//  GenericErrorDetails.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public struct GenericErrorDetails: TitleProviding, CustomStringConvertible {
    public let description: String
    public let title: String
    public let thirdPartyErrorCode: String?

    public init(title: String? = nil, description: String, thirdPartyErrorCode: String? = nil) {
        self.description = description
        self.title = title ?? "Error"
        self.thirdPartyErrorCode = thirdPartyErrorCode
    }

    public static func from(error: Error) -> GenericErrorDetails {
        return GenericErrorDetails(title: "Error", description: error.localizedDescription)
    }
}

extension GenericErrorDetails: Codable {}
