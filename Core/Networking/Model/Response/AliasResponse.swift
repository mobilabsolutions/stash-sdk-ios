//
//  CreateAliasResponse.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct AliasResponse: Codable {
    let aliasId: String
    let extra: AliasExtra?
    let psp: PSPExtra
}
