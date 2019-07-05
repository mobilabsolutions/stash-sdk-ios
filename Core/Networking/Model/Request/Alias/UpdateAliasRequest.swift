//
//  UpdateAliasRequest.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct UpdateAliasRequest: Codable {
    let aliasId: String
    let pspAlias: String?
    let extra: AliasExtra
    let idempotencyKey: String

    enum UpdateAliasRequestKeys: String, CodingKey {
        case pspAlias
        case extra
    }
}
