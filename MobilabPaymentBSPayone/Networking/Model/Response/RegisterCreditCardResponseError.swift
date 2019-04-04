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
    let customerMessage: String

    func toMobilabPaymentError() -> MobilabPaymentError {
        return MobilabPaymentError.pspError(self.errorMessage)
    }

    enum CodingKeys: String, CodingKey {
        case status
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case customerMessage = "customermessage"
    }
}
