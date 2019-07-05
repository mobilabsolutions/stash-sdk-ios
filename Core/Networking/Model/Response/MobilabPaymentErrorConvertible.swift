//
//  MLErrorConvertible.swift
//  MobilabPaymentCore
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public protocol MobilabPaymentErrorConvertible {
    func toMobilabPaymentError() -> MobilabPaymentError
}
