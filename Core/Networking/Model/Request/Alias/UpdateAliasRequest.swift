//
//  UpdateAliasRequest.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct UpdateAliasRequest: Codable {
    let aliasId: String
    let pspAlias: String
    let extra: AliasExtra
}
