//
//  MobilabBackendError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct MobilabBackendError: Codable {
    let description: String
    let code: String

    enum CodingKeys: String, CodingKey {
        case description = "error_description"
        case code = "error_code"
    }
}

extension MobilabBackendError: MobilabPaymentErrorConvertible {
    func toMobilabPaymentError() -> MobilabPaymentError {
        guard let errorCodeCategory = code.first.flatMap(String.init)
        else {
            let details = GenericErrorDetails(title: "Error", description: description)
            return MobilabPaymentError.other(details)
        }

        switch errorCodeCategory {
        case "3":
            let configurationError = SDKConfigurationError.invalidBackendConfiguration(description: description, code: code)
            return MobilabPaymentError.configuration(configurationError)
        default:
            let error = GenericErrorDetails(title: "Error", description: description, thirdPartyErrorCode: code)
            return MobilabPaymentError.other(error)
        }
    }
}
