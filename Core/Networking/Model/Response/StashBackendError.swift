//
//  StashBackendError.swift
//  StashCore
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct StashBackendError: Codable {
    let description: String
    let code: String
    let title: String?

    enum CodingKeys: String, CodingKey {
        case description = "error_description"
        case title = "error"
        case code = "error_code"
    }
}

extension StashBackendError: StashErrorConvertible {
    func toStashError() -> StashError {
        guard let errorCodeCategory = code.first.flatMap(String.init)
        else {
            let details = GenericErrorDetails(title: title ?? "Error", description: description)
            return StashError.other(details)
        }

        switch errorCodeCategory {
        case "3":
            let configurationError = SDKConfigurationError.invalidBackendConfiguration(title: self.title ?? "Error", description: self.description, code: self.code)
            return StashError.configuration(configurationError)
        default:
            let error = GenericErrorDetails(title: title ?? "Error", description: description, thirdPartyErrorCode: code)
            return StashError.other(error)
        }
    }
}
