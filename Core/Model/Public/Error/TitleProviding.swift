//
//  TitleProviding.swift
//  StashCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A protocol that requires an associated human-readable title
public protocol TitleProviding {
    /// A human readable title that describes the given instance
    var title: String { get }
}
