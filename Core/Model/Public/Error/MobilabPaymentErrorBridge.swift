//
//  MobilabPaymentErrorBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge that allows accessing `MobilabPaymentError`s from Objective-C
@objc(MLError) public class MobilabPaymentErrorBridge: NSObject {
    /// The original error's title
    @objc public let title: String
    /// The original error's description
    @objc public let errorDescription: String

    /// Create a bridge instance from an original error
    ///
    /// - Parameter mobilabPaymentError: The original error
    public init(mobilabPaymentError: MobilabPaymentError) {
        self.title = mobilabPaymentError.title
        self.errorDescription = mobilabPaymentError.description
        super.init()
    }
}
