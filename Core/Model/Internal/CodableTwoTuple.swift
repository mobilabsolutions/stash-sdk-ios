//
//  CodableTwoTuple.swift
//  StashCore
//
//  Created by Robert on 30.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct CodableTwoTuple<S: Codable, T: Codable>: Codable {
    let first: S
    let second: T
}
