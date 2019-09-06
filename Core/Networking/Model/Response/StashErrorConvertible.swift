//
//  MLErrorConvertible.swift
//  StashCore
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// An error that can be converted into a StashError representation
public protocol StashErrorConvertible {
    /// Create a StashError representation for this error
    func toStashError() -> StashError
}
