//
//  RegistrationResult.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public typealias RegistrationResult = Result<String?, MobilabPaymentError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

public struct Registration {
    public let pspAlias: String?
    public let aliasExtra: AliasExtra

    public init(pspAlias: String?, aliasExtra: AliasExtra) {
        self.pspAlias = pspAlias
        self.aliasExtra = aliasExtra
    }
}
