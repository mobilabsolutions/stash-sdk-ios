//
//  TemporaryErrorDetails.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct TemporaryErrorDetails: TitleProviding, CustomStringConvertible {
    public let title: String
    public let description: String
    public let thirdPartyErrorCode: String?

    public init(title: String? = nil, description: String, thirdPartyErrorCode: String? = nil) {
        self.title = title ?? "Temporary Error"
        self.description = description
        self.thirdPartyErrorCode = thirdPartyErrorCode
    }
}

extension TemporaryErrorDetails: Codable {}
