//
//  RegisterResponseError.swift
//  MobilabPaymentAdyen
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
        #warning("Perform correct mapping of result code to errors here")
        return MobilabPaymentError.other(GenericErrorDetails(description: self.refusalReason, thirdPartyErrorCode: self.resultCode.rawValue))
    }
}
