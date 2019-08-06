//
//  PSPRegistration.swift
//  StashCore
//
//  Created by Robert on 17.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// The result of registering a payment method with a PSP
public struct PSPRegistration {
    /// The PSP alias that was created
    public let pspAlias: String?
    /// The extra that should be forwarded to the backend PSP module
    public let aliasExtra: AliasExtra
    /// A possible extra alias information to use if the default payment method's information is not
    /// accurate.
    public let overwritingExtraAliasInfo: PaymentMethodAlias.ExtraAliasInfo?

    public init(pspAlias: String?, aliasExtra: AliasExtra,
                overwritingExtraAliasInfo: PaymentMethodAlias.ExtraAliasInfo? = nil) {
        self.pspAlias = pspAlias
        self.aliasExtra = aliasExtra
        self.overwritingExtraAliasInfo = overwritingExtraAliasInfo
    }
}
