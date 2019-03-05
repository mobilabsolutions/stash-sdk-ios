//
//  CreateAliasResponse.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct AliasResponse: Codable {

    var aliasId: String
    var extra: AliasExtra?
    var psp: PSPExtra
}
