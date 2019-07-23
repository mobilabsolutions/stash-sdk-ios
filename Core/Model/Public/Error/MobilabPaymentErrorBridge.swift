//
//  MobilabPaymentErrorBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLError) public class MobilabPaymentErrorBridge: NSObject {
    @objc public let title: String
    @objc public let errorDescription: String

    public init(mobilabPaymentError: MobilabPaymentError) {
        self.title = mobilabPaymentError.title
        self.errorDescription = mobilabPaymentError.description
        super.init()
    }
}
