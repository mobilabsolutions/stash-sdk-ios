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
        let temporaryErrors: Set = [
            // Card issuer not available
            "1", "91",
            // DB Connection Failure
            "909",
            // Status Change Not Possible
            "950",
            // Maintenance
            "990", "991",
            // Service Unavailable
            "6502",
        ]

        switch self.errorCode {
        case isContainedIn(temporaryErrors):
            return MobilabPaymentError.temporary(TemporaryErrorDetails(description: self.errorMessage, thirdPartyErrorCode: self.errorCode))
        default:
            #warning("Update this with correct data when PSP error mapping is done")
            return MobilabPaymentError.other(GenericErrorDetails(description: self.errorMessage, thirdPartyErrorCode: self.errorCode))
        }
    }

    enum CodingKeys: String, CodingKey {
        case status
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case customerMessage = "customermessage"
    }
}
