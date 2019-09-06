//
//  CreateAliasResponse.swift
//  StashCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct CreateAliasResponse: Codable {
    let aliasId: String
    let psp: PSPExtra
}
