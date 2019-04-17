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
            // Temporary error
            "904",
            // Payment failed at third party.
            "983",
        ]

        let userActionRequiredErrors: Set = [
            // CVC2 code incorrect length or incorrect syntax
            "879",
            // Country of the account not supported.
            "892",
            // Expiry date invalid, incorrect or in the past
            "33",
            // Required CVC code not specified or not valid
            "7",
            // Invalid card
            "14",
            // Manipulation suspected
            "34",
            // Card stolen
            "43",
            // Incorrect secret code / Wrong PIN
            "55",
            // Card unknown
            "56",
            // Card is not allowed. Card is blocked.
            "61", "62", "63",
            // Card has been used too often
            "65",
            // Risk assessment has denied this transaction.
            "107", "890",
            // Payment denied after [xyz] check
            "701", "702", "703", "704", "731", "732", "733", "734",
            // Invalid card number
            "877", "878",
            // Card type does not correspond with card number
            "880",
            // Bank details cannot be used for online banking.
            "881",
            // Bank type not supported
            "882",
            // Parameter [xyz] faulty or missing
            "1000", "1079", "1078", "1077", "1110", "1111", "1115", "1301", "1302", "1340",
            "4010", "4011",
        ]

        switch self.errorCode {
        case isContainedIn(temporaryErrors):
            return MobilabPaymentError.temporary(TemporaryErrorDetails(description: self.customerMessage ?? self.errorMessage, thirdPartyErrorCode: self.errorCode))
        case isContainedIn(userActionRequiredErrors):
            return MobilabPaymentError.userActionable(UserActionableErrorDetails(description: self.customerMessage ?? self.errorMessage, thirdPartyErrorCode: self.errorCode))
        default:
            return MobilabPaymentError.other(GenericErrorDetails(description: self.customerMessage ?? self.errorMessage, thirdPartyErrorCode: self.errorCode))
        }
    }

    enum CodingKeys: String, CodingKey {
        case status
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case customerMessage = "customermessage"
    }
}
