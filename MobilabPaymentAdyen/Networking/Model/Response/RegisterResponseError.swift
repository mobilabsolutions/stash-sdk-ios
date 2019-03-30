//
//  RegisterCreditCardResponseError.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

struct RegisterResponseError: MLErrorConvertible, Codable {
    let resultCode: ResultCode
    let refusalReason: String

    func toMLError() -> MLError {
        #warning("Find sensible default value for code once errors are finalized")
        return MLError(title: "PSP Error",
                       description: self.refusalReason,
                       code: -1)
    }

    enum CodingKeys: String, CodingKey {
        case resultCode
        case refusalReason
    }
}
