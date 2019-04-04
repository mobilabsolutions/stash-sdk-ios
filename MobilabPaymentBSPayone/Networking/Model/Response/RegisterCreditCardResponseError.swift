//
//  RegisterCreditCardResponseError.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct RegisterCreditCardResponseError: MobilabPaymentErrorConvertible, Codable {
    let status: StatusType
    let errorCode: String
    let errorMessage: String
    let customerMessage: String?

    func toMobilabPaymentError() -> MobilabPaymentError {
        switch self.errorCode {
        // Card issuer not available
        case "1", "91": fallthrough
        // DB Connection Failure
        case "909": fallthrough
        // Status Change Not Possible
        case "950": fallthrough
        // Maintenance
        case "990", "991": fallthrough
        // Service Unavailable
        case "6502":
            return MobilabPaymentError.pspTemporaryError(self.errorMessage)
        default:
            return MobilabPaymentError.pspError(self.errorMessage)
        }
    }

    enum CodingKeys: String, CodingKey {
        case status
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case customerMessage = "customermessage"
    }
}
