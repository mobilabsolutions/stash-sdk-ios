//
//  UpdateAliasRequest.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct UpdateAliasRequest: Codable {
    var aliasId: String
    var pspAlias: String
    var extra: AliasExtra

    init(aliasId: String, pspAlias: String, extra: AliasExtra) {
        self.aliasId = aliasId
        self.pspAlias = pspAlias
        self.extra = extra
    }
}
