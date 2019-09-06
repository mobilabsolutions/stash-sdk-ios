//
//  Country.swift
//  StashCore
//
//  Created by Rupali Ghate on 14.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A country that the user might be in
public struct Country {
    /// The country's name
    public let name: String
    /// The country's code
    public let alpha2Code: String

    public init(name: String, alpha2Code: String) {
        self.name = name
        self.alpha2Code = alpha2Code
    }
}
