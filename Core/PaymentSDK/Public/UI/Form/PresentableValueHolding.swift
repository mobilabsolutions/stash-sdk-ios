//
//  PresentableValueHolding.swift
//  MobilabPaymentCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A container for values that should also be presented in the UI
public protocol PresentableValueHolding {
    /// The title that can be presented in the UI
    var title: String { get }
    /// The value backing the title
    var value: Any { get }
}
