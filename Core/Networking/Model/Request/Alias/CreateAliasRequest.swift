//
//  CreateAliasRequest.swift
//  StashCore
//
//  Created by Borna Beakovic on 21/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct CreateAliasRequest: Codable {
    let pspType: String
    let aliasDetail: AliasCreationDetail?
    let idempotencyKey: String
}
