//
//  UserActionableErrorDetails.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct UserActionableErrorDetails: CustomStringConvertible, TitleProviding {
    public let title: String = "Error"
    public let description: String
    public let thirdPartyErrorCode: String

    public init(description: String, thirdPartyErrorCode: String) {
        self.description = description
        self.thirdPartyErrorCode = thirdPartyErrorCode
    }
}
