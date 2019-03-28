//
//  RegisterCreditCardResponseError.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct RegisterCreditCardResponseError: MLErrorConvertible, Codable {
    let status: StatusType
    let errorCode: String
    let errorMessage: String
    let customerMessage: String

    func toMLError() -> MLError {
        #warning("Find sensible default value for code once errors are finalized")
        return MLError(title: "PSP Error",
                       description: self.errorMessage,
                       code: Int(self.errorCode) ?? -1)
    }

    enum CodingKeys: String, CodingKey {
        case status
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case customerMessage = "customermessage"
    }
}
