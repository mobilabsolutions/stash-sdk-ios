//
//  RegisterCreditCardResponseError.swift
//  StashBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

struct RegisterCreditCardResponseError: StashErrorConvertible, Codable {
    let status: StatusType
    let errorCode: String
    let errorMessage: String
    let customerMessage: String?

    func toStashError() -> StashError {
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

        let genericValidationErrors: Set = [
            // Country of the account not supported.
            "892",
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
            // Card type does not correspond with card number
            "880",
            // Bank details cannot be used for online banking.
            "881",
            // Bank type not supported
            "882",
            // Parameter [xyz] faulty or missing
            "1000", "1079", "1078", "1077", "1110", "1111", "1115", "1301", "1302", "1340",
            "4010", "4011",
            // Card type does not correspond with card number
            "880",
        ]

        let cvvErrors = [
            // CVC2 code incorrect length or incorrect syntax
            "879",
            // Required CVC code not specified or not valid
            "7",
        ]

        let cardErrors = [
            // Invalid card
            "14",
            // Invalid card number
            "877", "878",
        ]

        let dateErrors = [
            // Expiry date invalid, incorrect or in the past
            "33",
        ]

        switch self.errorCode {
        case isContainedIn(temporaryErrors):
            return StashError.temporary(TemporaryErrorDetails(description: self.customerMessage ?? self.errorMessage, thirdPartyErrorCode: self.errorCode))
        case isContainedIn(cvvErrors):
            return StashError.validation(.invalidCVV)
        case isContainedIn(cardErrors):
            return StashError.validation(.invalidCreditCardNumber)
        case isContainedIn(dateErrors):
            return StashError.validation(.invalidExpirationDate)
        case isContainedIn(genericValidationErrors):
            let details = ValidationErrorDetails.other(description: self.customerMessage ?? self.errorMessage,
                                                       thirdPartyErrorDetails: self.errorCode)
            return StashError.validation(details)
        default:
            return StashError.other(GenericErrorDetails(description: self.customerMessage ?? self.errorMessage, thirdPartyErrorCode: self.errorCode))
        }
    }

    enum CodingKeys: String, CodingKey {
        case status
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case customerMessage = "customermessage"
    }
}
