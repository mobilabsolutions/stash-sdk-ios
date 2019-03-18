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

extension MobilabBackendError: MLErrorConvertible {
    func toMLError() -> MLError {
        #warning("Update this when error codes are finalized")
        return MLError(description: self.message, code: 103)
    }
}
