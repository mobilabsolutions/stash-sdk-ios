//
//  PSPRegistration.swift
//  MobilabPaymentCore
//
//  Created by Robert on 17.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

/// The result of registering a payment method with a PSP
public struct PSPRegistration {
    /// The PSP alias that was created
    public let pspAlias: String?
    /// The extra that should be forwarded to the backend PSP module
    public let aliasExtra: AliasExtra
    /// A possible human readable identifier to use if the default payment method's identifier is not
    /// accurate.
    public let overwritingHumanReadableIdentifier: String?

    public init(pspAlias: String?, aliasExtra: AliasExtra,
                overwritingHumanReadableIdentifier: String? = nil) {
        self.pspAlias = pspAlias
        self.aliasExtra = aliasExtra
        self.overwritingHumanReadableIdentifier = overwritingHumanReadableIdentifier
    }
}
