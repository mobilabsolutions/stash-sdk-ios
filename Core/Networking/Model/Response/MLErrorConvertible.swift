//
//  MLErrorConvertible.swift
//  MobilabPaymentCore
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public protocol MLErrorConvertible {
    func toMLError() -> MLError
}
