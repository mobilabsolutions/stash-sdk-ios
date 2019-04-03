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
        return MobilabPaymentError.backendError(self.message)
    }
}
