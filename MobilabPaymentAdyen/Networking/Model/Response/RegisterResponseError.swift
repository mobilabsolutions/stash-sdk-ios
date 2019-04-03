//
//  RegisterCreditCardResponseError.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct RegisterResponseError: MobilabPaymentErrorConvertible, Codable {
    let resultCode: ResultCode
    let refusalReason: String

    func toMobilabPaymentError() -> MobilabPaymentError {
        return MobilabPaymentError.pspError(self.refusalReason)
    }

    enum CodingKeys: String, CodingKey {
        case resultCode
        case refusalReason
    }
}
