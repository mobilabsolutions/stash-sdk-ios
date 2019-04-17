//
//  MobilabBackendError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct MobilabBackendError: Codable {
    let message: String
}

extension MobilabBackendError: MobilabPaymentErrorConvertible {
    func toMobilabPaymentError() -> MobilabPaymentError {
        #warning("When error format of BE is decided, update this")
        let details = GenericErrorDetails(title: "Error", description: message)
        return MobilabPaymentError.other(details)
    }
}
