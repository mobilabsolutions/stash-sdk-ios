//
//  Header.swift
//  StashCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct Header {
    let field: String
    let value: String

    init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}
